-- mini file 文件浏览/管理
-- <leader>e 打开于当前文件
-- <leader>E 打开于根目录
return {
    "nvim-mini/mini.files",
    lazy = false,
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
    },
    config = function(_, opts)
        require("mini.files").setup(opts)

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesActionRename",
            callback = function(event)
                require("snacks").rename.on_rename_file(event.data.from, event.data.to)
            end,
        })
    end,
}
