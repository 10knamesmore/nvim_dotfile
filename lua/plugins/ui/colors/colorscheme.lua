return {
    {
        "folke/tokyonight.nvim",
        lazy = true, -- make sure we load this during startup if it is your main colorscheme
        opts = function()
            vim.api.nvim_set_hl(0, "@keyword.import.rust", { link = "@Keyword" })
            return {
                transparent = false,
                style = "moon",
                styles = {
                    functions = { italic = true, bold = true },
                    keywords = { italic = true, bold = true },
                },
                ---@param highlights tokyonight.Highlights
                ---@param colors ColorScheme
                on_highlights = function(highlights, _)
                    require("tokyonight")
                    highlights["String"].italic = true
                    highlights["Constant"].italic = true
                    highlights["Constant"].bold = true
                end,
            }
        end,
    },
    {
        "rebelot/kanagawa.nvim",
        opts = {},
    },
    {
        "bluz71/vim-moonfly-colors",
        name = "moonfly",
        lazy = false,
        priority = 1000,
    },
    {
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
        opts = {
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            integrations = {
                aerial = true,
                alpha = true,
                cmp = true,
                dashboard = true,
                flash = false,
                fzf = true,
                grug_far = true,
                gitsigns = true,
                headlines = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                leap = true,
                lsp_trouble = true,
                mason = true,
                markdown = true,
                mini = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                    },
                },
                navic = { enabled = true, custom_bg = "lualine" },
                neotest = true,
                neotree = true,
                noice = true,
                notify = true,
                semantic_tokens = true,
                snacks = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                which_key = true,
            },
        },
    },
}
