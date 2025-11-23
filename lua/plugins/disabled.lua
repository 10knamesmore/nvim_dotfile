return {
    {
        import = "nvim-neo-tree/neo-tree.nvim",
        enabled = false,
    },
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        enabled = false,
        keys = {
            { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
            -- { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
            { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "删除右侧的 buffer" },
            { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "删除左侧的 buffer" },
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
            -- { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
            -- { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
            { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
            { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
        },
        opts = {
            options = {
                close_command = function(n)
                    Snacks.bufdelete(n)
                end,
                right_mouse_command = function(n)
                    -- Snacks.bufdelete(n)
                end,
                diagnostics = "nvim_lsp",
                always_show_bufferline = false,
                diagnostics_indicator = function(_, _, diag)
                    local icons = LazyVim.config.icons.diagnostics
                    local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                        .. (diag.warning and icons.Warn .. diag.warning or "")
                    return vim.trim(ret)
                end,
                indicator = {
                    icon = "▎", -- this should be omitted if indicator style is not 'icon'
                    style = "icon",
                },
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Neo-tree",
                        highlight = "Directory",
                        text_align = "left",
                    },
                    {
                        filetype = "snacks_layout_box",
                    },
                },
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = { "close" },
                },
                -- separator_style = "slant" | "slope" | "thick" | "thin" | { "any", "any" },
                separator_style = "slope",
                ---@param opts bufferline.IconFetcherOpts
                get_element_icon = function(opts)
                    return LazyVim.config.icons.ft[opts.filetype]
                end,
                sort_by = function(buffer_a, buffer_b)
                    -- -- add custom logic
                    -- local modified_a = vim.fn.getftime(buffer_a.path)
                    -- local modified_b = vim.fn.getftime(buffer_b.path)
                    -- return modified_a > modified_b
                    return buffer_a.id < buffer_b.id
                end,
            },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
                callback = function()
                    vim.schedule(function()
                        pcall(nvim_bufferline)
                    end)
                end,
            })
        end,
    },
    {
        "rmagatti/goto-preview", -- 插件名称：用于“预览跳转”功能，如函数定义/引用的浮动窗口预览
        enabled = false,
        dependencies = { "rmagatti/logger.nvim" }, -- 插件依赖项（记录日志用）
        event = "BufEnter", -- 在进入缓冲区时懒加载该插件

        config = true, -- 启用自动加载 setup 配置（必须为 true，否则 issue #88 会导致失效）

        opts = {
            width = 240, -- 浮动窗口的宽度（字符宽）
            height = 100, -- 浮动窗口的高度（行数）
            border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- 浮动窗口的边框样式，依次为 ↖ 上 右上 右 右下 下 左下 左 左
            default_mappings = true, -- 是否使用默认快捷键（例如：`gpd`, `gpt` 等）
            debug = false, -- 是否输出调试信息（通常设为 false）
            opacity = nil, -- 窗口透明度，范围 0~100，100 是完全透明（nil 表示默认不透明）
            resizing_mappings = false, -- 是否启用方向键调整浮动窗口大小
            post_open_hook = nil, -- 在浮动窗口打开后执行的钩子函数（可自定义）
            post_close_hook = nil, -- 在浮动窗口关闭后执行的钩子函数（可自定义）

            references = {
                provider = "telescope", -- 引用预览列表所使用的 UI 组件：支持 telescope/fzf_lua/snacks/mini_pick/default
                telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
                -- telescope 的具体配置：使用下拉样式，且不隐藏右侧 preview 区域
            },

            focus_on_open = true, -- 打开浮动窗口时自动聚焦（获得输入焦点）
            dismiss_on_move = false, -- 移动光标时是否自动关闭浮动窗口（false 表示保持打开）
            force_close = true, -- 是否使用 `force` 方式关闭浮动窗口（对应 vim.api.nvim_win_close 的第二参数）
            bufhidden = "wipe", -- 设置浮动窗口中的 buffer 的隐藏行为为 wipe，详见 :h bufhidden
            stack_floating_preview_windows = true, -- 是否允许浮动窗口叠加（多个窗口堆叠显示）
            same_file_float_preview = true, -- 当前文件内的符号引用是否也使用浮动窗口打开
            preview_window_title = {
                enable = true, -- 是否显示窗口标题（显示文件名）
                position = "left", -- 标题显示在窗口的左边
            },
            zindex = 1, -- 浮动窗口的 z-index 层级（用于叠加窗口排序）
            vim_ui_input = true, -- 是否使用 goto-preview 的浮动窗口替代 `vim.ui.input`（可用于插件交互）
        },
    },
    {
        "MagicDuck/grug-far.nvim",
        enabled = false,
    },
}
