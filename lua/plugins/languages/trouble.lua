---@class trouble.Mode: trouble.Config,trouble.Section.spec
---@field desc? string
---@field sections? string[]

---@class trouble.Config
---@field mode? string
---@field config? fun(opts:trouble.Config)
---@field formatters? table<string,trouble.Formatter> custom formatters
---@field filters? table<string, trouble.FilterFn> custom filters
---@field sorters? table<string, trouble.SorterFn> custom sorters
local defaults = {
    auto_close = false, -- 当没有条目时自动关闭窗口
    auto_open = false, -- 当有条目时自动打开窗口
    auto_preview = true, -- 移动到某条目时自动打开预览窗口
    auto_refresh = true, -- 打开时自动刷新数据
    auto_jump = false, -- 当只有一个条目时是否自动跳转
    focus = false, -- 打开窗口时是否自动聚焦该窗口
    restore = true, -- 打开时是否恢复上次打开的位置
    follow = true, -- 是否跟随当前项（光标移动时自动更新高亮）
    indent_guides = true, -- 是否显示缩进引导线
    max_items = 200, -- 每个 section 中最多显示的条目数
    multiline = true, -- 是否渲染多行消息
    pinned = false, -- 将 Trouble 窗口与当前 buffer 绑定，保持一致
    warn_no_results = true, -- 如果没有结果是否弹出警告
    open_no_results = false, -- 没有结果时是否仍然打开窗口
    ---@type trouble.Window.opts
    win = {}, -- 主窗口配置项（可以设置为分屏、浮窗等）
    ---@type trouble.Window.opts
    preview = {
        type = "main", -- 预览显示在主窗口中
        scratch = true, -- 当 buffer 未加载时是否使用临时 scratch buffer（不写入磁盘，启用语法高亮）
    },
    ---@type table<string, number|{ms:number, debounce?:boolean}>

    throttle = {
        refresh = 20, -- 自动刷新间隔，单位：ms
        update = 10, -- 窗口更新间隔
        render = 10, -- 渲染间隔
        follow = 100, -- 自动跟随间隔
        preview = { ms = 100, debounce = true }, -- 预览显示的防抖设置
    },
    ---@type table<string, trouble.Action.spec|false>

    keys = {
        ["?"] = "help", -- 显示帮助
        r = "refresh", -- 刷新内容
        R = "toggle_refresh", -- 开启/关闭自动刷新
        q = "close", -- 关闭 Trouble 窗口
        o = "jump_close", -- 跳转并关闭窗口
        ["<esc>"] = "cancel", -- 取消操作
        ["<cr>"] = "jump", -- 跳转到选中的条目
        ["<2-leftmouse>"] = "jump", -- 鼠标双击跳转
        ["<c-s>"] = "jump_split", -- 跳转并水平分屏
        ["<c-v>"] = "jump_vsplit", -- 跳转并垂直分屏

        -- 向下跳转（可以带计数）
        ["}"] = "next",
        ["]]"] = "next",

        -- 向上跳转（可以带计数）
        ["{"] = "prev",
        ["[["] = "prev",

        dd = "delete", -- 删除当前项
        d = { action = "delete", mode = "v" }, -- 可视模式下删除

        i = "inspect", -- 查看详情
        p = "preview", -- 打开预览
        P = "toggle_preview", -- 开关预览窗口

        -- 折叠/展开相关命令
        zo = "fold_open",
        zO = "fold_open_recursive",
        zc = "fold_close",
        zC = "fold_close_recursive",
        za = "fold_toggle",
        zA = "fold_toggle_recursive",
        zm = "fold_more",
        zM = "fold_close_all",
        zr = "fold_reduce",
        zR = "fold_open_all",
        zx = "fold_update",
        zX = "fold_update_all",
        zn = "fold_disable",
        zN = "fold_enable",
        zi = "fold_toggle_enable",

        -- 自定义动作：过滤当前 buffer
        gb = {
            action = function(view)
                view:filter({ buf = 0 }, { toggle = true })
            end,
            desc = "切换当前 buffer 的过滤器",
        },

        -- 自定义动作：切换严重等级过滤器
        s = {
            action = function(view)
                local f = view:get_filter("severity")
                local severity = ((f and f.filter.severity or 0) + 1) % 5
                view:filter({ severity = severity }, {
                    id = "severity",
                    template = "{hl:Title}Filter:{hl} {severity}",
                    del = severity == 0,
                })
            end,
            desc = "切换严重程度过滤器",
        },
    },
    ---@type table<string, trouble.Mode>

    modes = {
        lsp_references = {
            params = {
                include_declaration = true, -- 是否包含定义
            },
        },
        lsp_base = {
            params = {
                include_current = false, -- 不包含当前位置
            },
        },
        symbols = {
            desc = "文档符号",
            mode = "lsp_document_symbols",
            focus = false,
            win = { position = "right" }, -- 显示在右侧
            filter = {
                ["not"] = { ft = "lua", kind = "Package" }, -- 在 Lua 中不显示 "Package" 类符号
                any = {
                    ft = { "help", "markdown" }, -- 在这些文件类型中显示全部
                    kind = { -- 默认符号种类
                        "Class",
                        "Constructor",
                        "Enum",
                        "Field",
                        "Function",
                        "Interface",
                        "Method",
                        "Module",
                        "Namespace",
                        "Package",
                        "Property",
                        "Struct",
                        "Trait",
                    },
                },
            },
        },
    },
    -- stylua: ignore
    icons = {
        ---@type trouble.Indent.symbols
        indent = {
        top           = "│ ",
        middle        = "├╴",
        last          = "└╴",
        -- last          = "-╴",
        -- last       = "╰╴", -- rounded
        fold_open     = " ",
        fold_closed   = " ",
        ws            = "  ",
        },
        folder_closed   = " ",
        folder_open     = " ",
        kinds = {
        Array         = " ",
        Boolean       = "󰨙 ",
        Class         = " ",
        Constant      = "󰏿 ",
        Constructor   = " ",
        Enum          = " ",
        EnumMember    = " ",
        Event         = " ",
        Field         = " ",
        File          = " ",
        Function      = "󰊕 ",
        Interface     = " ",
        Key           = " ",
        Method        = "󰊕 ",
        Module        = " ",
        Namespace     = "󰦮 ",
        Null          = " ",
        Number        = "󰎠 ",
        Object        = " ",
        Operator      = " ",
        Package       = " ",
        Property      = " ",
        String        = " ",
        Struct        = "󰆼 ",
        TypeParameter = " ",
        Variable      = "󰀫 ",
        },
    },
}
return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
        modes = {
            symbols = { -- Configure symbols mode
                win = {
                    type = "split", -- split window
                    relative = "win", -- relative to current window
                    position = "left", -- right side
                    size = 0.25,
                },
            },
            diagnostics = {
                win = {
                    type = "split",
                    relative = "win",
                    position = "bottom",
                    size = 0.20,
                },
            },
        },
        keys = {
            ["l"] = "jump", -- 跳转到选中的条目
        },
    },
    keys = {
        { "<leader>gd", "<CMD>Trouble diagnostics toggle<CR>", desc = "[Trouble Toggle buffer diagnostics]" },
    },
}
