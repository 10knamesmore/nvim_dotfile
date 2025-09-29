-- 更好的yank
-- <leader>p 打开复制的历史
-- p 复制到光标后
-- P 复制到光标前
return {
    "gbprod/yanky.nvim",
    recommended = true,
    desc = "Better Yank/Paste",
    event = "LazyFile",
    opts = {
        highlight = { timer = 150 },
    },
    keys = {
        {
            "<leader>p",
            function()
                if LazyVim.pick.picker.name == "telescope" then
                    require("telescope").extensions.yank_history.yank_history({})
                else
                    vim.cmd([[YankyRingHistory]])
                end
            end,
            mode = { "n", "x" },
            desc = "Open Yank History",
        },
        -- stylua: ignore
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
    },
}
