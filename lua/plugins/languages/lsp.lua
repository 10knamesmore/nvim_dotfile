return {
    {
        "mason-org/mason.nvim",
        keys = function()
            return {}
        end,
    },
    -- LSP keymaps
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            servers = {
                ["*"] = {
                    keys = {
                        { "K", "7gk", desc = "Move up 7 lines" },
                    },
                },
            },
        },
    },
}
