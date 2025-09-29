-- 格式化插件配置
return {
    "stevearc/conform.nvim", -- 插件名称，Conform 是一个异步格式化器，支持多种语言

    dependencies = { "mason.nvim" }, -- 插件依赖：使用 mason.nvim 来安装/管理格式化工具

    lazy = true, -- 延迟加载插件，不在启动时立刻加载

    cmd = "ConformInfo", -- 执行 :ConformInfo 命令时加载插件（用来查看可用 formatter 信息）

    init = function()
        -- vim.api.nvim_create_user_command("Format", function(args)
        --     local range = nil
        --     if args.count ~= -1 then
        --         local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        --         range = {
        --             start = { args.line1, 0 },
        --             ["end"] = { args.line2, end_line:len() },
        --         }
        --     end
        --     require("conform").format({ async = true, lsp_format = "fallback", range = range })
        -- end, { range = true })
        LazyVim.on_very_lazy(function()
            LazyVim.format.register({
                name = "conform.nvim", -- 注册的格式化器名称
                priority = 100, -- 优先级，数值越大越靠前（用于控制多 formatter 情况下的选择）
                primary = true, -- 是否为主格式化器（true 表示优先使用 conform）

                -- 真正执行格式化的函数
                format = function(bufnr)
                    -- 自定义：禁用某些 filetype 的自动格式化
                    local ignore_filetypes = {}
                    local buf_ft = vim.bo[bufnr].filetype
                    if vim.tbl_contains(ignore_filetypes, buf_ft) then
                        vim.notify(
                            "跳过格式化：filetype '" .. buf_ft .. "' 被配置为禁止格式化",
                            vim.log.levels.INFO
                        )
                        return
                    end

                    -- 全局变量或 buffer 变量用于禁用格式化功能
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        vim.notify(
                            "跳过格式化：已设置禁用标志（g/b.disable_autoformat）",
                            vim.log.levels.DEBUG
                        )
                        return
                    end

                    -- 使用内建的高亮 yank 效果
                    vim.hl.on_yank()

                    -- 如果文件路径在 node_modules 中，或者是 min 文件，跳过格式化
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    if bufname:match("/node_modules/") or bufname:match("%.min%.") then
                        vim.notify("跳过格式化：文件路径不符合格式化要求", vim.log.levels.DEBUG)
                        return
                    end

                    -- 获取 conform 模块
                    local conform = require("conform")

                    -- 打印当前 buffer 可用的 formatter（debug 用）
                    local formatter_names = conform.list_formatters_for_buffer(bufnr)
                    vim.notify_once(
                        "可用的 formatters " .. vim.inspect(formatter_names),
                        vim.log.levels.DEBUG,
                        { title = "conform" }
                    )

                    -- 执行格式化
                    conform.format({
                        bufnr = bufnr,
                    })
                end,

                -- 获取可用于该 buffer 的 formatter 名称列表（用于显示等）
                sources = function(buf)
                    local ret = require("conform").list_formatters(buf)
                    ---@param v conform.FormatterInfo
                    return vim.tbl_map(function(v)
                        return v.name
                    end, ret)
                end,
            })
        end)
    end,

    -- 插件选项设置
    opts = function()
        local options = {
            -- 默认格式化参数
            default_format_opts = {
                timeout_ms = 3000, -- 超时时间
                async = false, -- 不建议修改，表示同步格式化
                quiet = false, -- 不建议修改，控制是否静默
                lsp_format = "fallback", -- 是否 fallback 到 LSP 提供的格式化（如果 formatter 不可用）
            },

            -- 不同文件类型对应的格式化器设置
            formatters_by_ft = {
                lua = { "stylua" },
                fish = { "fish_indent" },
                sh = { "shfmt" },
                cpp = { "clang-format" },
                c = { "clang-format" },
                python = { "ruff_format" },
                rust = { "rustfmt" },
                javascript = { "prettierd", "prettier" }, -- 先尝试 prettierd
                json = { "prettierd", "prettier" },
                html = { "prettierd", "prettier" },
                css = { "prettierd", "prettier" },
            },
        }
        vim.keymap.set("", "<leader>=", function()
            require("conform").format({ async = true, lsp_fallback = true })
        end, { desc = "[F]ormat" })

        return options
    end,
}
