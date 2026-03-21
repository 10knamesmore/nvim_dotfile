-- mini file 文件浏览/管理
-- <leader>e 打开于当前文件
--
local path_utils = require("utils.path")

local filter_show = function(_)
    return true
end

local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
end

local root_augroup = vim.api.nvim_create_augroup("MiniFilesTabRoot", { clear = false })

local set_tab_root_on_file_enter = function(tab_id)
    local autocmd_id

    autocmd_id = vim.api.nvim_create_autocmd("BufEnter", {
        group = root_augroup,
        callback = function(args)
            if vim.api.nvim_get_current_tabpage() ~= tab_id then
                return
            end

            local buf_id = args.buf
            local filetype = vim.bo[buf_id].filetype
            if vim.bo[buf_id].buftype ~= "" or filetype == "minifiles" or filetype == "minifiles-help" then
                return
            end

            local filepath = path_utils.bufpath(buf_id)
            local stat = filepath and vim.uv.fs_stat(filepath) or nil
            if not stat or stat.type ~= "file" then
                return
            end

            local roots = path_utils.detect({ all = false, buf = buf_id })
            local root = roots[1] and roots[1].paths[1] or vim.fs.dirname(filepath) or vim.uv.cwd()
            if root and root ~= "" then
                vim.cmd.tcd(vim.fn.fnameescape(root))
            end

            pcall(vim.api.nvim_del_autocmd, autocmd_id)
        end,
    })
end

local open_mini_files_in_new_tab = function()
    local current_path = vim.api.nvim_buf_get_name(0)
    local anchor = current_path ~= "" and current_path or vim.uv.cwd()

    vim.cmd.tabnew()
    set_tab_root_on_file_enter(vim.api.nvim_get_current_tabpage())
    require("mini.files").open(anchor, true)
end

local map_split = function(buf_id, lhs, direction)
    local rhs = function()
        -- Make new window and set it as target
        local cur_target = MiniFiles.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
            vim.cmd(direction .. " split")
            return vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target)

        require("mini.files").go_in()
        -- This intentionally doesn't act on file under cursor in favor of
        -- explicit "go in" action (`l` / `L`). To immediately open file,
        -- add appropriate `MiniFiles.go_in()` call instead of this comment.
    end

    -- Adding `desc` will result into `show_help` entries
    local desc = "Split " .. direction
    vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

return {
    "nvim-mini/mini.files",
    keys = {
        {
            "<leader>e",
            function()
                require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
            end,
            desc = "Open mini.files (current file)",
        },
        {
            "<leader>tn",
            open_mini_files_in_new_tab,
            desc = "New tab with mini.files",
        },
    },
    opts = {
        windows = {
            preview = true,
            width_preview = 80,
        },
        content = { filter = filter_hide },
        mappings = {
            trim_left = "H",
            trim_right = "L",
            reset = "<Esc>",
        },
        options = {
            permanent_delete = false,
        },
    },
    config = function(_, opts)
        require("mini.files").setup(opts)

        -- 默认显示
        local show_dotfiles = false

        local toggle_dotfiles = function()
            show_dotfiles = not show_dotfiles
            local new_filter = show_dotfiles and filter_show or filter_hide
            require("mini.files").refresh({ content = { filter = new_filter } })
        end

        --- 复制文件名
        local yank_filename = function()
            local filepath = (MiniFiles.get_fs_entry() or {}).path
            if filepath == nil then
                vim.notify("Cursor is not on valid entry", vim.log.levels.WARN)
                return
            end

            local filename = vim.fs.basename(filepath)
            vim.fn.setreg("+", filename)
            vim.notify("Yanked filename: " .. filename, vim.log.levels.INFO)
        end

        --- 复制文件路径
        local yank_filepath = function()
            local filepath = (MiniFiles.get_fs_entry() or {}).path
            if filepath == nil then
                vim.notify("Cursor is not on valid entry", vim.log.levels.WARN)
                return
            end

            vim.fn.setreg("+", filepath)
            vim.notify("Yanked absolute path: " .. filepath, vim.log.levels.INFO)
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                vim.keymap.set("n", ".", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
                vim.keymap.set("n", "gy", yank_filename, { buffer = buf_id, desc = "Yank Filename" })
                vim.keymap.set("n", "gY", yank_filepath, { buffer = buf_id, desc = "Yank Absolute Path" })
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesActionRename",
            callback = function(event)
                require("snacks").rename.on_rename_file(event.data.from, event.data.to)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesWindowOpen",
            callback = function(args)
                local win_id = args.data.win_id

                -- Customize window-local settings
                vim.wo[win_id].winblend = 10
                local config = vim.api.nvim_win_get_config(win_id)
                config.border, config.title_pos = "rounded", "right"
                vim.api.nvim_win_set_config(win_id, config)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                -- Tweak keys to your liking
                map_split(buf_id, "<C-s>", "belowright horizontal")
                map_split(buf_id, "<C-v>", "belowright vertical")
            end,
        })
    end,
}
