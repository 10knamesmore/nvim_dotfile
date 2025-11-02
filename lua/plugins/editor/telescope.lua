return {
    "nvim-telescope/telescope.nvim",
    keys = function()
        return {
            {
                "?",
                ":Telescope current_buffer_fuzzy_find<Cr>",
                desc = "search in current buffer",
            },
            {
                "<leader>,",
                "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
                desc = "Switch Buffer",
            },
            { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
            { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
            { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
            -- find
            {
                "<leader>fb",
                "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
                desc = "Buffers",
            },
            -- { "<leader>fc", LazyVim.pick.config_files(), desc = "nvim Config File" },
            { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
            -- search
            { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
            { "<leader>sb", ":Telescope buffers sort_mru=true sort_lastused=true<Cr>", desc = "Buffers" },
            { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
            { "<leader>sC", "<cmd>Telescope command_history<cr>", desc = "Command History" },
            { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
            { "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer Diagnostics" },
            { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
            { "<leader>sf", "<cmd>Telescope filetypes<cr>", desc = "Change Current Filetypes" },
            { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
            { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
            { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
            { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
            { "<leader>uC", LazyVim.pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with Preview" },
            {
                "<leader>ss",
                function()
                    require("telescope.builtin").lsp_document_symbols({
                        symbols = LazyVim.config.get_kind_filter(),
                    })
                end,
                desc = "Goto Symbol",
            },
            {
                "<leader>sS",
                function()
                    require("telescope.builtin").lsp_dynamic_workspace_symbols({
                        symbols = LazyVim.config.get_kind_filter(),
                    })
                end,
                desc = "Goto Symbol (Workspace)",
            },
        }
    end,
}
