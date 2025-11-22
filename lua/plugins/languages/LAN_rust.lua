--- TODO: 配置rustlsp server
vim.g.lazyvim_rust_diagnostics = "rust-analyzer" -- "bacon-ls" or "rust-analyzer"

local diagnostics = vim.g.lazyvim_rust_diagnostics or "rust-analyzer"

return {
    -- rust 生命周期可视化
    {
        "cordx56/rustowl",
        version = "*", -- Latest stable version
        enabled = false,
        build = "cargo binstall rustowl",
        lazy = false, -- This plugin is already lazy
        opts = {
            auto_attach = falsej,
            highlight_style = "underline",
            client = {
                on_attach = function(_, buffer)
                    vim.keymap.set("n", "<leader>uo", function()
                        require("rustowl").toggle(buffer)
                    end, { buffer = buffer, desc = "Toggle RustOwl" })
                end,
            },
        },
    },

    -- LSP for Cargo.toml
    {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
            completion = {
                crates = {
                    enabled = true,
                },
            },
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
        },
    },

    -- Add Rust & related to treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "rust", "ron" } },
    },

    -- Ensure Rust debugger is installed
    {
        "mason-org/mason.nvim",
        optional = true,
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "codelldb" })
            if diagnostics == "bacon-ls" then
                vim.list_extend(opts.ensure_installed, { "bacon" })
            else
                vim.list_extend(opts.ensure_installed, { "rust-analyzer" })
            end
        end,
    },

    {
        "mrcjkb/rustaceanvim",
        ft = { "rust" },
        --- @type rustaceanvim.Opts
        opts = {
            server = {
                -- see https://rust-analyzer.github.io/book/configuration
                default_settings = {
                    -- rust-analyzer language server configuration
                    ["rust-analyzer"] = {
                        cargo = {
                            -- TODO: 想一个方法能配置传给cargo的features
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            buildScripts = {
                                enable = true,
                            },
                        },
                        -- Add clippy lints for Rust if using rust-analyzer
                        checkOnSave = diagnostics == "rust-analyzer",
                        -- Enable diagnostics if using rust-analyzer
                        diagnostics = {
                            enable = diagnostics == "rust-analyzer",
                        },
                        inlayHints = {
                            closureCaptureHints = {
                                enable = true,
                            },
                            -- genericParameterHints = { type = { enable = true } },
                        },
                        procMacro = {
                            enable = true,
                        },
                        files = {
                            exclude = {
                                ".direnv",
                                ".git",
                                ".jj",
                                ".github",
                                ".gitlab",
                                "node_modules",
                                "target",
                                "venv",
                                ".venv",
                            },
                            -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
                            watcher = "client",
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            if utils.plugins.has("mason.nvim") then
                local codelldb = vim.fn.exepath("codelldb")
                local codelldb_lib_ext = io.popen("uname"):read("*l") == "Linux" and ".so" or ".dylib"
                local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)
                opts.dap = {
                    adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
                }
            end
            vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
            if vim.fn.executable("rust-analyzer") == 0 then
                vim.notify(
                    "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
                    vim.log.levels.WARN
                )
            end
        end,
    },

    -- Correctly setup lspconfig for Rust 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                bacon_ls = {
                    enabled = diagnostics == "bacon-ls",
                },
                rust_analyzer = { enabled = false },
            },
        },
    },

    {
        "nvim-neotest/neotest",
        optional = true,
        opts = {
            adapters = {
                ["rustaceanvim.neotest"] = {},
            },
        },
    },
}
