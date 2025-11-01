return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
        modes = {
            symbols = { -- Configure symbols mode
                win = {
                    type = "split", -- split window
                    relative = "win", -- relative to current window
                    position = "left", -- right side
                    size = 0.25,
                },
            },
            diagnostics = {
                win = {
                    type = "split",
                    relative = "win",
                    position = "bottom",
                    size = 0.20,
                },
            },
        },
        keys = {
            ["l"] = "jump", -- 跳转到选中的条目
        },
    },
    keys = {
        { "<leader>gd", "<CMD>Trouble diagnostics toggle<CR>", desc = "[Trouble Toggle buffer diagnostics]" },
    },
}
