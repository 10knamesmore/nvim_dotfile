local colors = {
    black = "#1a1b26",
    white = "#c0caf5",
    red = "#f7768e",
    green = "#9ece6a",
    blue = "#7aa2f7",
    yellow = "#e0af68",
    purple = "#9d7cd8",
    gray = "#a9b1d6",
    darkgray = "#2a2e3f",
    lightgray = "#3b4261",
    inactivegray = "#414868",
}

local my_theme = {
    normal = {
        a = { bg = colors.blue, fg = colors.black, gui = "bold" },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.gray },
        y = { bg = colors.lightgray, fg = colors.white },
    },
    insert = {
        a = { bg = colors.red, fg = colors.black, gui = "bold" },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.white },
        y = { bg = colors.lightgray, fg = colors.red },
    },
    visual = {
        a = { bg = colors.purple, fg = colors.black, gui = "bold" },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.white },
        y = { bg = colors.lightgray, fg = colors.purple },
    },
    replace = {
        a = { bg = colors.red, fg = colors.black, gui = "bold" },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.white },
    },
    command = {
        a = { bg = colors.yellow, fg = colors.black, gui = "bold" },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.white },
        y = { bg = colors.lightgray, fg = colors.yellow },
    },
    inactive = {
        a = { bg = colors.darkgray, fg = colors.gray, gui = "bold" },
        b = { bg = colors.darkgray, fg = colors.gray },
        c = { bg = colors.darkgray, fg = colors.gray },
    },
    terminal = {
        a = { bg = colors.green, fg = colors.black, gui = "bold" },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.white },
        y = { bg = colors.lightgray, fg = colors.green },
    },
}
return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
            -- set an empty statusline till lualine loads
            vim.o.statusline = " "
        else
            -- hide the statusline on the starter page
            vim.o.laststatus = 0
        end
    end,
    opts = function()
        -- PERF: we don't need this lualine require madness 🤷
        local lualine_require = require("lualine_require")
        lualine_require.require = require

        local icons = LazyVim.config.icons

        vim.o.laststatus = vim.g.lualine_laststatus

        local opts = {
            options = {
                theme = my_theme,
                -- theme = "catppuccin",
                globalstatus = vim.o.laststatus == 3,
                disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
            },

            sections = {
                -- 左上角：显示当前模式，比如 NORMAL、INSERT
                lualine_a = { "mode" },

                -- 左侧第二段：显示 git 分支
                lualine_b = { "branch" },

                -- 中间部分：文件路径 + 文件类型图标 + diagnostics 信息
                lualine_c = {
                    -- 显示项目根目录（LazyVim 提供的封装）
                    LazyVim.lualine.root_dir(),
                    -- 显示 LSP diagnostics 信息
                    {
                        "diagnostics",
                        symbols = {
                            error = icons.diagnostics.Error, -- 错误数量
                            warn = icons.diagnostics.Warn, -- 警告数量
                            info = icons.diagnostics.Info, -- 信息数量
                            hint = icons.diagnostics.Hint, -- 提示数量
                        },
                    },

                    -- 只显示文件类型图标（不带文件类型名称），紧贴着路径前面
                    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },

                    -- 显示格式化后的路径（类似 VSCode 状态栏的文件路径），LazyVim 封装函数
                    { LazyVim.lualine.pretty_path() },
                },

                -- 右侧：展示性能信息、Noice 状态、DAP 状态、Lazy 插件更新数、Git diff 状态等
                lualine_x = {
                    -- snacks.nvim 提供的性能状态（如 FPS、启动耗时等）
                    Snacks.profiler.status(),

                    -- Noice 插件：当前命令提示（如输入 : 时的命令输入）
                    {
                        function()
                            return require("noice").api.status.command.get()
                        end,
                        cond = function()
                            return package.loaded["noice"] and require("noice").api.status.command.has()
                        end,
                        color = function()
                            return { fg = Snacks.util.color("Statement") }
                        end,
                    },

                    -- Noice 插件：当前交互模式（如输入中、选择中等）
                    {
                        function()
                            return require("noice").api.status.mode.get()
                        end,
                        cond = function()
                            return package.loaded["noice"] and require("noice").api.status.mode.has()
                        end,
                        color = function()
                            return { fg = Snacks.util.color("Constant") }
                        end,
                    },

                    -- nvim-dap 插件：显示当前调试状态
                    {
                        function()
                            return "  " .. require("dap").status()
                        end,
                        cond = function()
                            return package.loaded["dap"] and require("dap").status() ~= ""
                        end,
                        color = function()
                            return { fg = Snacks.util.color("Debug") }
                        end,
                    },

                    -- Lazy 插件：有插件可更新时显示更新数量
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = function()
                            return { fg = Snacks.util.color("Special") }
                        end,
                    },

                    -- Git diff 状态（新增、修改、删除）
                    {
                        "diff",
                        symbols = {
                            added = icons.git.added,
                            modified = icons.git.modified,
                            removed = icons.git.removed,
                        },
                        -- 使用 gitsigns 插件提供的缓存 diff 数据源
                        source = function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if gitsigns then
                                return {
                                    added = gitsigns.added,
                                    modified = gitsigns.changed,
                                    removed = gitsigns.removed,
                                }
                            end
                        end,
                    },
                },

                -- 倒数第二栏：进度百分比 + 行列号
                lualine_y = {
                    { "encoding", separator = "", padding = { left = 1, right = 1 } },
                    { "filesize" },
                    { "progress", separator = " ", padding = { left = 1, right = 0 } },
                    { "location", padding = { left = 0, right = 1 } },
                },

                -- 最右侧：显示当前时间（24小时制）
                lualine_z = {
                    function()
                        return " " .. os.date("%R")
                    end,
                },
            },
            extensions = { "neo-tree", "lazy", "fzf" },
        }

        -- do not add trouble symbols if aerial is enabled
        -- And allow it to be overriden for some buffer types (see autocmds)
        if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
            local trouble = require("trouble")
            local symbols = trouble.statusline({
                mode = "symbols",
                groups = {},
                title = false,
                filter = { range = true },
                format = "{kind_icon}{symbol.name:Normal}",
                hl_group = "lualine_c_normal",
            })
            table.insert(opts.sections.lualine_c, {
                symbols and symbols.get,
                cond = function()
                    return vim.b.trouble_lualine ~= false and symbols.has()
                end,
            })
        end

        return opts
    end,
}
