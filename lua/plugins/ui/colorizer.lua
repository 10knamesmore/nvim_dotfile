-- 把hex用色块表现
return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    config = function()
        require("colorizer").setup({
            filetypes = { "*" }, -- 针对哪些文件类型启用高亮，"*" 表示所有文件类型
            buftypes = {}, -- 针对哪些 buffer 类型启用高亮，留空表示所有 buffer 类型
            user_commands = true, -- 启用插件提供的用户命令（如 :ColorizerToggle 等）

            lazy_load = false, -- 是否懒加载高亮功能，false 表示立即加载当前缓冲区

            user_default_options = {
                names = false, -- 启用颜色名字（如 "blue", "red"）的高亮
                names_opts = { -- 配置颜色名字高亮时的匹配策略
                    lowercase = true, -- 匹配小写的名字（如 "blue"）
                    camelcase = true, -- 匹配驼峰命名（如 "Blue"）
                    uppercase = false, -- 不匹配全大写（如 "BLUE"）
                    strip_digits = false, -- 是否忽略带数字的颜色名（如 "red4"）
                },

                names_custom = false, -- 自定义颜色名字映射（例如 { sky = "#87ceeb" }），false 表示关闭

                RGB = true, -- 支持 #RGB 格式（如 #abc）
                RGBA = true, -- 支持 #RGBA 格式（如 #abcd）
                RRGGBB = true, -- 支持 #RRGGBB 格式（如 #aabbcc）
                RRGGBBAA = false, -- 关闭 #RRGGBBAA 格式（带 alpha 通道的8位 hex）
                AARRGGBB = true, -- 开启 0xAARRGGBB 格式 (为了yabai JankyBorders)（以0x开头的8位颜色）

                rgb_fn = false, -- 不启用 CSS 的 rgb()、rgba() 函数支持
                hsl_fn = false, -- 不启用 CSS 的 hsl()、hsla() 函数支持
                css = false, -- 是否启用所有 CSS 特性（包括名字、RGB、RGBA 等）
                css_fn = false, -- 是否启用所有 CSS 函数（rgb_fn 和 hsl_fn）

                tailwind = false, -- 关闭 TailwindCSS 的颜色高亮（true/'normal'/'lsp'/'both'）
                tailwind_opts = {
                    update_names = false, -- 如果开启 tailwind='both'，是否通过 LSP 更新 Tailwind 名字
                },

                sass = {
                    enable = false,
                    parsers = { "css" }, -- sass 文件也使用 css 的语法解析器
                },

                mode = "background", -- 使用背景色高亮（可选值：'background'、'foreground'、'virtualtext'）

                virtualtext = "■", -- 用于 virtual text 模式时显示的符号
                virtualtext_inline = true, -- virtual text 是否显示在行内（true/'before'/'after'）
                virtualtext_mode = "foreground", -- virtual text 的颜色来自于前景色

                always_update = false, -- 是否在 buffer 不处于焦点时仍更新颜色（适用于 cmp 补全等情况）

                hooks = {
                    disable_line_highlight = false, -- 是否禁用整行的高亮（可以是布尔值或函数）
                },
            },
        })
    end,
}
