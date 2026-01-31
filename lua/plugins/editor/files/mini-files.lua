-- mini file 文件浏览/管理
-- <leader>e 打开于当前文件
--
local filter_show = function(fs_entry)
    return true
end

local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
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

        local yank_path = function()
            local path = (MiniFiles.get_fs_entry() or {}).path
            if path == nil then
                return vim.notify("Cursor is not on valid entry")
            end
            vim.notify("Yanked: " .. path)
            vim.fn.setreg(vim.v.register, path)
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                vim.keymap.set("n", ".", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
                vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
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
