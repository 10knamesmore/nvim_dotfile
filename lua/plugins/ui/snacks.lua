-- 定义仪表盘各个部分的配置
--- @type snacks.dashboard.Section
local dashboard_sections = {
    {
        ttl = 0,
        enabled = function()
            return vim.o.lines > 40 and vim.o.columns > 100
        end,
        section = "terminal",
        cmd = 'ascii-image-converter -c --color -H50 "' .. vim.fn.stdpath("config") .. '/data/mutsumi.jpg"',
        height = 50,
        padding = 2,
        align = "center",
    },
    -- { section = "keys", gap = 1, padding = 1 }, -- 显示按键绑定，设置间距与边距
    {
        pane = 1,
        icon = " ", -- 图标
        title = "Recent Files", -- 标题
        section = "recent_files", -- 显示最近打开的文件
        indent = 2, -- 缩进
        padding = 1, -- 边距
    },
    {
        pane = 1,
        icon = " ",
        title = "Projects", -- 显示项目列表
        section = "projects",
        indent = 2,
        padding = 1,
    },
    { section = "startup" }, -- 启动状态
}

-- 插件定义与主配置导出
return {
    "folke/snacks.nvim",
    priority = 1000, -- 优先加载
    lazy = false, -- 启动时立即加载插件
    ---@type snacks.Config
    opts = {
        animate = { enabled = true, fps = 180 }, -- 启用动画效果，帧率为 180
        bigfile = { enabled = false }, -- 启用大文件处理优化, 交给bigfil.lua处理
        dashboard = { enabled = true, sections = dashboard_sections, width = 100 }, -- 启用仪表盘功能并加载定义的各部分
        explorer = { enabled = false, replace_netrw = false }, -- 文件浏览器功能禁用
        input = { enabled = true }, -- 启用输入增强（如 float 弹窗输入）
        profiler = { enabled = false },
        indent = {
            indent = {
                enabled = true, -- 启用缩进线
            },
            scope = {
                enabled = true, -- 启用作用域缩进高亮
                underline = false, -- 不使用下划线
                hl = { -- 定义每层缩进的高亮组
                    "SnacksIndent1",
                    "SnacksIndent2",
                    "SnacksIndent3",
                    "SnacksIndent4",
                    "SnacksIndent5",
                    "SnacksIndent6",
                    "SnacksIndent7",
                    "SnacksIndent8",
                },
            },
            chunk = {
                enabled = true, -- 启用块级缩进高亮
                hl = {
                    "SnacksIndent1",
                    "SnacksIndent2",
                    "SnacksIndent3",
                    "SnacksIndent4",
                    "SnacksIndent5",
                    "SnacksIndent6",
                    "SnacksIndent7",
                    "SnacksIndent8",
                },
                char = {
                    corner_top = "╭", -- 块顶部符号
                    corner_bottom = "╰", -- 块底部符号
                },
            },
        },
        notifier = { enabled = true }, -- 启用消息通知系统
        quickfile = { enabled = true }, -- 启用快速文件访问
        scroll = { enabled = false },
        scratch = {
            enabled = true,
            name = "草稿",
            ft = function()
                -- if vim.bo.buftype == "" and vim.bo.filetype ~= "" then
                --     return vim.bo.filetype
                -- end
                return "markdown"
            end,
            win = {
                width = 0.6,
                min_width = 100,
                height = 0.8,
                bo = { buftype = "", buflisted = false, bufhidden = "hide", swapfile = false },
                minimal = false,
                noautocmd = false,
                -- position = "right",
                zindex = 20,
                wo = { winhighlight = "NormalFloat:Normal" },
                footer_keys = true,
                border = "rounded",
                resize = true,
            },
        }, -- 启用 scratch buffer，并命名为“草稿”
        statuscolumn = { enabled = true }, -- 启用状态列（通常用于显示行号、git 标记等）
        words = { enabled = false }, -- 单词增强功能禁用
    },
    keys = {
        -- 禁用snacks exploers
        { "<leader>fe", mode = "n", false },
        { "<leader>fE", mode = "n", false },
        { "<leader>S", mode = "n", false },
        {
            "<leader>,",
            function()
                Snacks.scratch.select()
            end,
            desc = "Select Scratch Buffer",
        },
    },
}
