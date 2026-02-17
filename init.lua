_G.utils = require("utils")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.copilot_enabled = false

if vim.g.vscode then
    require("code.config.options")
    require("code.config.keymaps")
else
    if vim.g.neovide then
        -- 字体
        vim.o.guifont = "Hack Nerd Font:h10"

        -- 滚动动画
        vim.g.neovide_scroll_animation_length = 0.2
        -- 透明度

        vim.g.neovide_normal_opacity = 1

        -- 光标动画

        -- vim.g.neovide_transparency = 1
        vim.g.neovide_cursor_animation_length = 0.08
        vim.g.neovide_cursor_trail_size = 1
        vim.g.neovide_cursor_animate_in_insert_mode = true
    end
    require("config.lazy")
    require("config.keymaps")
    require("config.options")
    require("config.autocmds")
end
