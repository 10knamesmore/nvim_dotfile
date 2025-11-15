-- 格式化插件配置
return {
    "stevearc/conform.nvim",

    dependencies = { "mason.nvim" },

    lazy = true,

    cmd = "ConformInfo",

    init = function()
        -- Lazyvim 会注册 format on save, LazyFormat, FormatterInfo
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

                    -- 执行格式化
                    require("conform").format({
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
        vim.keymap.set("n", "=", function()
            require("conform").format({ async = true, lsp_fallback = true })
        end, { desc = "[F]ormat" })

        return options
    end,
}
