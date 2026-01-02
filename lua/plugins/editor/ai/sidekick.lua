return {
    -- copilot-language-server
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            local sk = LazyVim.opts("sidekick.nvim") ---@type sidekick.Config|{}
            if vim.tbl_get(sk, "nes", "enabled") ~= false then
                opts.servers = opts.servers or {}
                opts.servers.copilot = opts.servers.copilot or {}
            end
        end,
    },

    {
        "folke/sidekick.nvim",
        ---@type sidekick.Config
        opts = {
            nes = {
                enabled = true,
            },
            mux = {
                backend = "zellij",
                enabled = true,
            },
            cli = {
                prompts = {
                    changes = "请 review 我 git 更改的部分",
                    commit = "请为我生成一个合适的 git 提交信息",
                    diagnostics = "帮我修复这个文件的诊断信息 {file}?\n{diagnostics}",
                    document = "为这里添加文档注释 {function|line}",
                    explain = "详细解释, 包括背后底层原理,背景信息, 如何实现, 步骤如何 {this}",
                    fix = "帮我修复 {this}",
                    optimize = "如何优化 {this}?",
                    review = "帮我检查 {file} 是否有问题或改进之处?",
                    tests = "帮我为 {this} 编写测试",
                },
                win = {
                    layout = "float",
                    keys = {
                        hide_esc = { "<Esc>", "hide", mode = "n", desc = "hide the terminal window" },
                    },
                },
                picker = "telescope", ---@type sidekick.picker
            },
        },
        keys = {
            -- nes is also useful in normal mode
            {
                "<tab>",
                function()
                    if require("sidekick").nes_jump_or_apply() then
                        return
                    end
                    return "<tab>"
                end,
                mode = { "n", "i" },
                expr = true,
            },
            { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle({ filter = { installed = true } })
                end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>as",
                function()
                    require("sidekick.cli").select({ filter = { installed = true } })
                end,
                -- Or to select only installed tools:
                desc = "Select CLI",
            },
            {
                "<leader>ad",
                function()
                    require("sidekick.cli").close()
                end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function()
                    require("sidekick.cli").send({ msg = "{this}" })
                end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function()
                    require("sidekick.cli").send({ msg = "{file}" })
                end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function()
                    require("sidekick.cli").send({ msg = "{file}{selection}" })
                end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function()
                    require("sidekick.cli").prompt()
                end,
                mode = { "n", "x" },
                desc = "Prompt",
            },
        },
    },

    {
        "folke/snacks.nvim",
        optional = true,
        opts = {
            picker = {
                actions = {
                    sidekick_send = function(...)
                        return require("sidekick.cli.picker.snacks").send(...)
                    end,
                },
                win = {
                    input = {
                        keys = {
                            ["<a-a>"] = {
                                "sidekick_send",
                                mode = { "n", "i" },
                            },
                        },
                    },
                },
            },
        },
    },
}
