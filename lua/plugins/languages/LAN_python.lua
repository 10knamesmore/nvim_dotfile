return {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    config = function(_, opts)
        require("venv-selector").setup(opts)
        require("which-key").add({
            "<leader>v",
            group = "python venv",
        })
        vim.keymap.set({ "n", "x" }, "<leader>vs", "<cmd>VenvSelect<cr>")
        vim.keymap.set({ "n", "x" }, "<leader>vc", "<cmd>VenvSelectCached<cr>")
    end,
}
