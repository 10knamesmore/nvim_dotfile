-- mini file 文件浏览/管理
-- <leader>e 打开于当前文件
--
local filter_show = function()
    return true
end

local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
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
        local show_dotfiles = true

        local toggle_dotfiles = function()
            local new_filter = show_dotfiles and filter_show or filter_hide
            show_dotfiles = not show_dotfiles
            require("mini.files").refresh({ content = { filter = new_filter } })
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                vim.keymap.set("n", ".", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesActionRename",
            callback = function(event)
                require("snacks").rename.on_rename_file(event.data.from, event.data.to)
            end,
        })
    end,
}
