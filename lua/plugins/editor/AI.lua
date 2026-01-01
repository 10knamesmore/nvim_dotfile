-- CopilotChat.nvim 插件配置，为 Neovim 提供 AI 助手功能
return {
    {
        "folke/sidekick.nvim",
        opts = {
            -- Work with AI cli tools directly from within Neovim
            cli = {
                watch = true, -- notify Neovim of file changes done by AI CLI tools
                ---@class sidekick.win.Opts
                win = {
                    layout = "float", ---@type "float"|"left"|"bottom"|"top"|"right"
                    --- Options used when layout is "float"
                    ---@type vim.api.keyset.win_config
                    float = {
                        width = 0.9,
                        height = 0.9,
                    },
                    ---@type fun(dir:"h"|"j"|"k"|"l")?
                    --- Function that handles navigation between windows.
                    --- Defaults to `vim.cmd.wincmd`. Used by the `nav_*` keymaps.
                    nav = nil,
                },
                -- stylua: ignore
                ---@type table<string, sidekick.Prompt|string|fun(ctx:sidekick.context.ctx):(string?)>
                prompts = {
                    changes         = "Can you review my changes?",
                    diagnostics     = "Can you help me fix the diagnostics in {file}?\n{diagnostics}",
                    diagnostics_all = "Can you help me fix these diagnostics?\n{diagnostics_all}",
                    document        = "Add documentation to {function|line}",
                    explain         = "Explain {this}",
                    fix             = "Can you fix {this}?",
                    optimize        = "How can {this} be optimized?",
                    review          = "Can you review {file} for any issues or improvements?",
                    tests           = "Can you write tests for {this}?",
                    -- simple context prompts
                    buffers         = "{buffers}",
                    file            = "{file}",
                    line            = "{line}",
                    position        = "{position}",
                    quickfix        = "{quickfix}",
                    selection       = "{selection}",
                    ["function"]    = "{function}",
                    class           = "{class}",
                },
                -- preferred picker for selecting files
                picker = "telescope", ---@type sidekick.picker
            },
            copilot = {
                -- track copilot's status with `didChangeStatus`
                status = {
                    enabled = true,
                    level = vim.log.levels.WARN,
                    -- set to vim.log.levels.OFF to disable notifications
                    -- level = vim.log.levels.OFF,
                },
            },
            ui = {
            -- stylua: ignore
            icons = {
            attached          = " ",
            started           = " ",
            installed         = " ",
            missing           = " ",
            external_attached = "󰖩 ",
            external_started  = "󰖪 ",
            terminal_attached = " ",
            terminal_started  = " ",
            },
            },
            debug = false, -- enable debug logging
        },
        keys = {
            {
                "<tab>",
                function()
                    -- if there is a next edit, jump to it, otherwise apply it if any
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<Tab>" -- fallback to normal tab
                    end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<c-.>",
                function()
                    require("sidekick.cli").toggle()
                end,
                desc = "Sidekick Toggle",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle()
                end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>as",
                function()
                    require("sidekick.cli").select()
                end,
                -- Or to select only installed tools:
                -- require("sidekick.cli").select({ filter = { installed = true } })
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
                    require("sidekick.cli").send({ msg = "{selection}" })
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
                desc = "Sidekick Select Prompt",
            },
            -- Example of a keybinding to open Claude directly
            {
                "<leader>ac",
                function()
                    require("sidekick.cli").toggle({ name = "claude", focus = true })
                end,
                desc = "Sidekick Toggle Claude",
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
            table.insert(
                opts.sections.lualine_x,
                2,
                LazyVim.lualine.status(" ", function()
                    local clients = package.loaded["copilot"] and vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
                        or {}
                    if #clients > 0 then
                        local status = require("copilot.status").data.status
                        return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
                    end
                end)
            )
        end,
    },
    {
        "saghen/blink.cmp",
        optional = true,
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            sources = {
                providers = {
                    path = {
                        -- Path sources triggered by "/" interfere with CopilotChat commands
                        enabled = function()
                            return vim.bo.filetype ~= "copilot-chat"
                        end,
                    },
                },
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "copilot-chat" },
    },
}
