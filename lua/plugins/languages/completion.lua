return {
    "saghen/blink.cmp", -- 插件名称，blink.cmp 是一个补全框架，支持 LSP/snippet 等多种来源

    event = function()
        return { "BufReadPost", "BufNewFile" }
    end,
    version = "1.*",
    deppendencies = { "xzbdmw/colorful-menu.nvim", opts = {} },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {

        -- 根据文件类型控制插件是否启用
        enabled = function()
            -- 在 markdown 文件中禁用补全（如写文档时不希望触发自动补全）
            if vim.tbl_contains({ "markdown" }, vim.bo.filetype) then
                return false
            else
                return true
            end
        end,

        -- 是否启用命令行补全（默认关闭）
        cmdline = { enabled = false },

        -- 键位映射设置
        keymap = {
            preset = "none", -- 不使用预设，完全自定义
            ["<Up>"] = { "select_prev", "fallback" }, -- 向上选择补全项
            ["<Down>"] = { "select_next", "fallback" }, -- 向下选择补全项
            ["<Tab>"] = { "select_next", "fallback" }, -- Tab 选择下一个
            ["<S-Tab>"] = { "select_prev", "fallback" }, -- Shift-Tab 选择上一个
            ["<Cr>"] = { "accept", "fallback" }, -- 回车接受当前项
            ["<C-d>"] = { "cancel", "fallback" }, -- Ctrl-d 取消补全

            ["<C-n>"] = { "scroll_documentation_down", "fallback" }, -- 向下滚动文档
            ["<C-f>"] = { "scroll_documentation_up", "fallback" }, -- 向上滚动文档
        },

        -- 补全逻辑相关设置
        completion = {
            keyword = { range = "prefix" }, -- 匹配关键字的范围，使用前缀匹配

            accept = {
                auto_brackets = { enabled = true }, -- 自动接受时是否添加括号
            },

            list = {
                selection = {
                    preselect = true, -- 自动预选第一项
                    auto_insert = true, -- 自动插入选中的补全项
                },
            },

            menu = {
                auto_show = true, -- 自动显示补全菜单
                draw = {
                    columns = {
                        -- 第一列：图标 + label + 描述，紧凑排布
                        { "kind_icon", "label", gap = 0 },
                        -- 第二列：补全项的类型（如函数、变量等）
                        { "kind" },
                        -- 第三列：补全来源（如 lsp, buffer）
                        { "source_name" },
                    },
                    components = {
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                },
                -- border = "padded", -- 可启用边框（此处注释掉）
            },

            documentation = {
                auto_show = true, -- 自动显示补全项的文档说明
            },

            ghost_text = {
                show_with_menu = true, -- 在补全菜单显示时显示 ghost text（预测性补全文本）
            },
        },

        -- 外观设置
        appearance = {
            -- 使用普通 Nerd Font（normal 更适配非 mono 风格的图标）
            nerd_font_variant = "normal",
        },

        -- 默认启用的补全来源，其他配置中可通过 opts_extend 扩展此表
        sources = {
            default = { "lsp", "snippets", "buffer", "path" },
        },

        -- 模糊匹配设置
        fuzzy = {
            -- 优先使用 Rust 实现的算法，若失败则警告
            implementation = "prefer_rust_with_warning",

            sorts = {
                -- 自定义排序函数：将以 "_" 开头的补全项排到后面
                function(a, b)
                    local a_is_underscore = a.label:sub(1, 1) == "_"
                    local b_is_underscore = b.label:sub(1, 1) == "_"
                    if a_is_underscore ~= b_is_underscore then
                        return not a_is_underscore
                    end
                end,
                -- 然后按分数和排序文本排序
                "score",
                "sort_text",
            },
        },

        -- 启用函数参数签名提示
        signature = { enabled = true },
    },

    -- 使用 opts_extend 实现源列表的扩展合并，而非覆盖
    opts_extend = { "sources.default" },
}
