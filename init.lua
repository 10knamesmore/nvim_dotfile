_G.utils = require("utils")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.copilot_enabled = false

local init_neovide = function()
    -- 字体
    local os = require("utils.os").get_os()
    if os == "Linux" then
        vim.o.guifont = "VictorMono Nerd Font Mono:h14"
    elseif os == "Macos" then
        vim.o.guifont = "Victor Mono:h14"
    end

    -- 滚动动画
    vim.g.neovide_scroll_animation_length = 0.2
    -- 透明度

    vim.g.neovide_normal_opacity = 1

    -- 光标动画

    -- vim.g.neovide_transparency = 1
    vim.g.neovide_cursor_animation_length = 0.08
    vim.g.neovide_cursor_trail_size = 1
    vim.g.neovide_cursor_animate_in_insert_mode = true

    -- 增大/缩小字体快捷键
    local inc_font_key, dec_font_key
    if os == "Linux" then
        inc_font_key = "<C-+>"
        dec_font_key = "<C-_>"
    elseif os == "Macos" then
        inc_font_key = "<C-+>"
        dec_font_key = "<C-_>"
    end

    vim.keymap.set("n", inc_font_key, function()
        local font = vim.o.guifont
        local size = tonumber(font:match(":h(%d+)")) or 14
        vim.o.guifont = font:gsub(":h%d+", ":h" .. (size + 1))
    end, { desc = "Increase Font Size" })

    vim.keymap.set("n", dec_font_key, function()
        local font = vim.o.guifont
        local size = tonumber(font:match(":h(%d+)")) or 14
        if size > 6 then
            vim.o.guifont = font:gsub(":h%d+", ":h" .. (size - 1))
        end
    end, { desc = "Decrease Font Size" })
end

if vim.g.vscode then
    require("code.config.options")
    require("code.config.keymaps")
else
    if vim.g.neovide then
        init_neovide()
    end
    require("config.lazy")
    require("config.keymaps")
    require("config.options")
    require("config.autocmds")
end
