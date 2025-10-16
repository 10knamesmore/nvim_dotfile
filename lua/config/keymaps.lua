-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set
local function opts(desc)
    local opts = { noremap = true, silent = true }

    if desc then
        opts.desc = desc
    end
    return opts
end

keymap("n", "<Space>", "", opts())
keymap({ "n", "v" }, "q", "", opts())
vim.g.mapleader = " "

keymap({ "n", "v" }, "E", "$", opts())
keymap({ "n", "v" }, "B", "^", opts())
-- 模式切换
-- -- 插入模式下jk,kj退出
keymap("i", "jk", "<Esc>", opts())
keymap("i", "kj", "<Esc>", opts())
-- keymap({ "n", "v" }, "q", "<Esc>", opts)

-- 移动光标
keymap("n", "gb", "<C-o>", opts("LSP跳转返回"))
keymap("n", "<C-o>", "<C-i>", opts("LSP跳转返回"))
keymap("n", "<C-i>", "<C-o>", opts("LSP跳转返回"))
-- -- JK光标移动多行
keymap({ "n", "v" }, "J", "7gj", opts())
keymap({ "n", "v" }, "K", "7gk", opts())
-- -- 空格 + o/O 插入一行而不进入插入模式
keymap("n", "<leader>o", "o<Esc>", opts())
keymap("n", "<leader>O", "O<Esc>", opts())
keymap("n", "gm", "'", opts("跳转到标签"))

-- 移动__窗口
-- -- 大写 W 切换窗口焦点
keymap("n", "W", "<C-w>w", opts())
-- --  左右方向键切换标签页,上下方向键什么都不干
keymap("n", "<Left>", ":bp<CR>", opts())
keymap("n", "<Right>", ":bn<CR>", opts())
keymap("n", "<Up>", "", opts())
keymap("n", "<Down>", "", opts())

-- -- -- -- -- -- 插件相关 -- -- -- -- -- --
keymap("n", "<leader>cs", ":AerialToggle left<Cr>", opts())
keymap("n", "?", ":Telescope current_buffer_fuzzy_find<Cr>", opts("切换Buffer"))
keymap("n", "<leader>sB", ":Telescope buffers sort_mru=true sort_lastused=true<Cr>", opts("切换Buffer"))
