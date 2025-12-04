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
        opts = function(_, opts)
            opts.servers["*"].keys = {
                {
                    "<leader>cR",
                    function()
                        Snacks.rename.rename_file()
                    end,
                    desc = "Rename File",
                    mode = { "n" },
                    has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
                },
                { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
                { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
                {
                    "]]",
                    function()
                        Snacks.words.jump(vim.v.count1)
                    end,
                    has = "documentHighlight",
                    desc = "Next Reference",
                    enabled = function()
                        return Snacks.words.is_enabled()
                    end,
                },
                {
                    "[[",
                    function()
                        Snacks.words.jump(-vim.v.count1)
                    end,
                    has = "documentHighlight",
                    desc = "Prev Reference",
                    enabled = function()
                        return Snacks.words.is_enabled()
                    end,
                },
                {
                    "<a-n>",
                    function()
                        Snacks.words.jump(vim.v.count1, true)
                    end,
                    has = "documentHighlight",
                    desc = "Next Reference",
                    enabled = function()
                        return Snacks.words.is_enabled()
                    end,
                },
                {
                    "<a-p>",
                    function()
                        Snacks.words.jump(-vim.v.count1, true)
                    end,
                    has = "documentHighlight",
                    desc = "Prev Reference",
                    enabled = function()
                        return Snacks.words.is_enabled()
                    end,
                },
            }

            opts.diagnostics = {
                virtual_text = false,
            }
        end,
    },
}
