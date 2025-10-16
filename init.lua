-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.neovide then
    require("config.lazy")
    require("config.keymaps")
    require("config.options")
    -- 字体
    vim.o.guifont = "Hack Nerd Font:h15"

    -- 滚动动画
    vim.g.neovide_scroll_animation_length = 0.2
    -- 透明度

    vim.g.neovide_normal_opacity = 1

    -- 光标动画

    -- vim.g.neovide_transparency = 1
    vim.g.neovide_cursor_animation_length = 0.08
    vim.g.neovide_cursor_trail_size = 1
    vim.g.neovide_cursor_animate_in_insert_mode = true

    -- vim.g.neovide_cursor_animation_length = 0
    -- vim.g.neovide_cursor_trail_size = 0
    -- vim.g.neovide_cursor_animate_in_insert_mode = false

    -- 全屏
    -- vim.g.neovide_fullscreen = true
    --

    -- 输入的时候不显示鼠标
    -- vim.g.neovide_hide_mouse_when_typing = true

    -- 记住窗口大小
    -- vim.g.neovide_remember_window_size = true

    -- 全屏 --
    -- vim.keymap.set(
    --     { "n" },
    --     "<leader>wf",
    --     ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>",
    --     { noremap = true, silent = true, desc = "全屏" }
    -- )
elseif vim.g.vscode then
    require("code.config.options")
    require("code.config.keymaps")
else
    require("config.lazy")
    require("config.keymaps")
    require("config.options")
end
