return {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        bar = {
            enable = function(buf, win, _)
                if not vim.api.nvim_win_is_valid(win) then
                    return false
                end

                if vim.bo[buf].buftype ~= "" then
                    return false
                end

                local ignore_ft = {
                    "TelescopePrompt",
                    "Trouble",
                    "alpha",
                    "dashboard",
                    "help",
                    "lazy",
                    "mason",
                    "neo-tree",
                    "noice",
                    "notify",
                    "qf",
                    "snacks_dashboard",
                    "terminal",
                    "toggleterm",
                }

                return not vim.tbl_contains(ignore_ft, vim.bo[buf].filetype)
            end,
        },
        menu = {
            win_configs = {
                border = "rounded",
            },
        },
    },
    keys = {
        {
            "<leader>h",
            function()
                require("dropbar.api").pick()
            end,
            desc = "Dropbar Pick",
        },
        {
            "[;",
            function()
                require("dropbar.api").goto_context_start()
            end,
            desc = "Dropbar Prev Context",
        },
        {
            "];",
            function()
                require("dropbar.api").select_next_context()
            end,
            desc = "Dropbar Next Context",
        },
        {
            "<leader>s;",
            function()
                local api = require("dropbar.api")
                if type(api.pick_mode) == "function" then
                    api.pick_mode()
                else
                    api.pick()
                end
            end,
            desc = "Dropbar Pick (Compat)",
        },
    },
    config = function(_, opts)
        require("dropbar").setup(opts)
    end,
}
