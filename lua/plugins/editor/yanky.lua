-- <leader>sp 打开复制的历史
-- p 复制到光标后
-- P 复制到光标前
return {
    {
        "gbprod/yanky.nvim",
        desc = "Better Yank/Paste",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            highlight = { timer = 150 },
            picker = {
                select = {
                    action = nil,
                },
                telescope = {
                    use_default_mappings = true,
                    mappings = nil,
                },
            },
        },
        config = function(_, opts)
            require("yanky").setup(opts)
            vim.keymap.set("n", "<leader>sp", function()
                require("telescope").extensions.yank_history.yank_history({ initial_mode = "normal" })
            end, { noremap = true, silent = true, desc = "Open Yank History" })
        end,
        keys = {
            { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
        },
    },
}
