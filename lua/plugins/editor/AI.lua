-- CopilotChat.nvim 插件配置，为 Neovim 提供 AI 助手功能
return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        lazy = false,
        cmd = "CopilotChat", -- 通过 :CopilotChat 命令懒加载
        opts = function()
            -- 获取当前用户名，用于聊天头部显示
            local user = vim.env.USER or "User"
            user = user:sub(1, 1):upper() .. user:sub(2)

            --- @type CopilotChat.config.Config
            return {
                auto_insert_mode = false, -- 聊天窗口不自动进入插入模式
                language = "中文",
                resources = {}, -- 默认通过 # 传过去的, 什么都不传
                remember_as_sticky = true, --不把 models, tools, resources system_prompt 记为 sticky

                headers = {
                    user = "  " .. user .. " ", -- 用户头部图标和名称
                    assistant = "  Copilot ", -- AI 助手头部图标
                    tool = "󰊳  Tool ", -- 工具头部图标
                },
                window = {
                    width = 0.35,
                    border = "shadow",
                },

                log_level = "info",

                prompts = {
                    Explain = {
                        prompt = "请根据整个文件内容, 详细解释选择代码. 分为三个部分: 逻辑流程(先用markdown自然语言描述流程, 再考虑用unicode描述流程图), 功能(什么情况下执行, 输入是什么, 输出是什么), 以及在整体上起到的作用。",
                        -- system_prompt = "COPILOT_EXPLAIN",
                        resources = {
                            "selection",
                            "buffer:active",
                        },
                    },

                    Review = {
                        prompt = "请审查所选代码。",
                        system_prompt = [[[
你是一名专注于提升代码质量和可维护性的代码审查员。


请严格按照以下格式列出你发现的每个问题, severity取这一行最严重的问题的情况：
line=<行号>:severity <问题描述>
或
line=<起始行>-<结束行>:severity <问题描述>
比如
"""
line=117:INFO 命名callback不够具体，建议根据实际用途使用更具描述性的名称;response和source参数未加类型注释，影响可读性;缺少对callback函数的注释说明其作用和参数含义。
"""

其中severity是一个枚举类型，包含以下成员：
severity : {
  ERROR,
  WARN,
  INFO,
  HINT,
}
其中
ERROR：严重错误，影响程序正确性或存在安全隐患，如未处理的异常、明显的逻辑错误、资源泄漏、SQL注入等安全问题。
WARN：潜在问题，可能导致bug或维护困难，如复杂表达式、过深嵌套、性能隐患、错误处理不完善、违反SOLID原则等。
INFO：与代码逻辑无关但影响可读性或规范性的问题，如命名不规范、注释缺失/错误、风格不一致、代码重复、格式问题, 脚本语言缺少typehint等。
HINT：轻微建议或可选优化，如微小的风格改进、可读性提升建议、非强制性重构等。


请检查以下方面：
- 命名不清晰或不符合规范
- 注释质量（缺失, 错误）
- 需要简化的复杂表达式
- 过深的嵌套或复杂的控制流
- 风格或格式不一致, 或与当前语言的idom不符
- 代码重复或冗余
- 潜在的性能问题
- 错误处理缺失
- 安全隐患
- 违反SOLID原则

同一行的多个问题请用分号分隔。
最后以：“**`如需清除缓冲区高亮，请提出其他问题。`**”结尾。

如果未发现问题，请确认代码编写良好并说明原因。
                        ]],
                        callback = function(response, source)
                            local diagnostics = {}
                            for line in response.content:gmatch("[^\r\n]+") do
                                if line:find("^line=") then
                                    local start_line, end_line, message, severity
                                    -- 匹配 line=10:WARN 问题描述 或 line=10-12:ERROR 问题描述
                                    local single_match, sev, message_match = line:match("^line=(%d+):([A-Z]+)%s+(.*)$")
                                    if not single_match then
                                        local start_match, end_match, sev2, m_message_match =
                                            line:match("^line=(%d+)-(%d+):([A-Z]+)%s+(.*)$")
                                        if start_match and end_match then
                                            start_line = tonumber(start_match)
                                            end_line = tonumber(end_match)
                                            severity = sev2
                                            message = m_message_match
                                        end
                                    else
                                        start_line = tonumber(single_match)
                                        end_line = start_line
                                        severity = sev
                                        message = message_match
                                    end

                                    if start_line and end_line and severity then
                                        -- 映射 severity 字符串到 vim.diagnostic.severity
                                        local sev_map = {
                                            ERROR = vim.diagnostic.severity.ERROR,
                                            WARN = vim.diagnostic.severity.WARN,
                                            INFO = vim.diagnostic.severity.INFO,
                                            HINT = vim.diagnostic.severity.HINT,
                                        }
                                        -- TODO: 将message作为字符串, 用分号分割成数组 messages
                                        -- TODO: 遍历messages, 都insert
                                        for msg in message:gmatch("([^;]+)") do
                                            table.insert(diagnostics, {
                                                lnum = start_line - 1,
                                                end_lnum = end_line - 1,
                                                col = 0,
                                                message = vim.trim(msg),
                                                severity = sev_map[severity] or vim.diagnostic.severity.WARN,
                                                source = "Copilot Review",
                                            })
                                        end
                                    end
                                end
                            end
                            vim.diagnostic.set(
                                vim.api.nvim_create_namespace("copilot-chat-diagnostics"),
                                source.bufnr,
                                diagnostics
                            )
                        end,

                        resources = { "selection" },
                    },

                    Fix = {
                        prompt = "这段代码存在问题。请指出问题并重写修复后的代码，解释原问题及你的修复方案。",
                        resources = { "selection", "buffer:active" },
                    },

                    Optimize = {
                        prompt = "请优化所选代码以提升性能和可读性，并说明你的优化策略及其好处。",
                        resources = { "selection", "buffer:active" },
                    },

                    Docs = {
                        prompt = "请为所选代码添加文档注释并添加尽可能详细的typehints。",
                        resources = { "selection", "buffer:active" },
                    },

                    Tests = {
                        prompt = "请为我的代码生成测试用例。",
                        resources = { "selection", "buffer:active" },
                    },

                    Commit = {
                        prompt = "请根据 commitizen 规范为更改编写提交信息。标题保持在 50 个字符以内，正文每行不超过 72 个字符。以 gitcommit 代码块格式输出.",
                        resources = {
                            "gitdiff:staged",
                        },
                    },

                    Completion = {
                        prompt = "选中部分逻辑不完整, 请根据可能给出的TODO注释, 结合整体逻辑补全剩下部分",
                        resources = { "selection", "buffer:active" },
                    },
                },
            }
        end,
        keys = {
            -- CopilotChat 的快捷键映射
            { "<c-s>", "<CR>", ft = "CopilotChat", desc = "提交问题", remap = true },
            { "<leader>a", "", desc = "+ai", mode = { "n", "x" } }, -- AI 分组前缀
            {
                "<leader>aa",
                function()
                    return require("CopilotChat").toggle() -- 切换聊天窗口显示/隐藏
                end,
                desc = "切换 CopilotChat",
                mode = { "v", "n", "x" },
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
                    Snacks.input({
                        prompt = "快速提问: ",
                        win = {
                            title_pos = "left",
                            relative = "cursor",
                            col = -5,
                        },
                    }, function(input)
                        local system_prompt = [[
当你引用文件内容时, 为了让我更快找到上下文, 请用 
line:123-234 你的回答
的形式回复.
当你可以给出代码片段时, 请直接给出不需要听取我的意见,并用代码块的形式返回.
给出代码块不代表你需要停止回答, 你可以继续补充说明.
请尽可能详细地回答我的问题.
]]
                        if input ~= "" then
                            require("CopilotChat").reset()
                            require("CopilotChat").ask(input, {
                                system_prompt = system_prompt,
                                remember_as_sticky = true,
                                resources = { "selection", "buffer:active" }, -- 如果有选中内容，则将其作为资源传递给 AI
                            })
                        end
                    end)
                end,
                desc = "AI 快速提问（带上下文提示）",
                mode = { "v", "n", "x" },
            },
            {
                "<leader>ap",
                function()
                    require("CopilotChat").select_prompt() -- 显示提示操作
                end,
                desc = "选择预设 promts",
                mode = { "v", "n", "x" },
            },
            {
                "<leader>am",
                function()
                    require("CopilotChat").select_model() -- 选择 AI 提供商
                end,
                desc = "选择模型",
                mode = { "n" },
            },
            {
                "<leader>ao",
                function()
                    require("CopilotChat").open({ resources = {} })
                end,
                desc = "打开 CopilotChat 窗口",
                mode = { "v", "n", "x" },
            },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")

            -- 进入聊天 buffer 时隐藏行号
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "copilot-chat",
                callback = function()
                    -- TODO
                    vim.wo.signcolumn = "no"
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
                utils.lualine.status(" ", function()
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
