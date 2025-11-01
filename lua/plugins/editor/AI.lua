-- CopilotChat.nvim 插件配置，为 Neovim 提供 AI 助手功能
return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        cmd = "CopilotChat", -- 通过 :CopilotChat 命令懒加载
        opts =
            --- @return CopilotChat.config.Config
            function()
                -- 获取当前用户名，用于聊天头部显示
                local user = vim.env.USER or "User"
                user = user:sub(1, 1):upper() .. user:sub(2)

                return {
                    auto_insert_mode = false, -- 聊天窗口不自动进入插入模式
                    language = "中文",
                    headers = {
                        user = "  " .. user .. " ", -- 用户头部图标和名称
                        assistant = "  Copilot ", -- AI 助手头部图标
                        tool = "󰊳  Tool ", -- 工具头部图标
                    },
                    window = {
                        width = 0.4,
                        border = "rounded",
                    },
                }
            end,
        keys = {
            -- CopilotChat 的快捷键映射
            { "<c-s>", "<CR>", ft = "copilot-chat", desc = "提交问题", remap = true },
            { "<leader>a", "", desc = "+ai", mode = { "n", "x" } }, -- AI 分组前缀
            {
                "<leader>aa",
                function()
                    return require("CopilotChat").toggle() -- 切换聊天窗口显示/隐藏
                end,
                desc = "切换 CopilotChat",
                mode = { "n", "x" },
            },
            {
                "<leader>ax",
                function()
                    return require("CopilotChat").reset() -- 清空聊天历史
                end,
                desc = "清空 CopilotChat",
                mode = { "n", "x" },
            },
            {
                "<leader>aq",
                function()
                    -- 弹出输入框进行快速提问
                    vim.ui.input({
                        prompt = "快速提问: ",
                    }, function(input)
                        if input ~= "" then
                            require("CopilotChat").ask(input)
                        end
                    end)
                end,
                desc = "快速提问 CopilotChat",
                mode = { "n", "x" },
            },
            {
                "<leader>ap",
                function()
                    require("CopilotChat").select_prompt() -- 显示提示操作
                end,
                desc = "提示操作 CopilotChat",
                mode = { "n", "x" },
            },
            {
                "<leader>am",
                function()
                    require("CopilotChat").select_model() -- 选择 AI 提供商
                end,
                desc = "选择模型 CopilotChat",
                mode = { "n", "x" },
            },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")

            -- 进入聊天 buffer 时隐藏行号
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "copilot-chat",
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                end,
            })

            chat.setup(opts) -- 用配置初始化插件
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        optional = true,
        event = "VeryLazy",
        opts = function(_, opts)
            table.insert(
                opts.sections.lualine_x,
                2,
                LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
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
}
