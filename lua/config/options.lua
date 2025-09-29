local opt = vim.opt

-- 使用系统剪贴板
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.cursorline = true
-- 缩进设置
opt.autoindent = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.wrap = true
-- 搜索
opt.hlsearch = true -- 高亮搜索结果
opt.ignorecase = true
opt.smartcase = true
-- 外观
opt.termguicolors = true
opt.listchars = { tab = ">-", trail = "-" }

opt.undofile = false
opt.undodir = vim.fn.stdpath("state") .. "/nvim/undo"

-- 设置领导键为空格
vim.g.mapleader = " "
vim.o.updatetime = 200
vim.o.scrolloff = 5
vim.o.virtualedit = ""
vim.o.cmdheight = 0
-- 启用相对行号
vim.wo.relativenumber = true

vim.g.lazyvim_picker = "telescope"
