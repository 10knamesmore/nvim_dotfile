local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

local codeAction = function(command)
    return "<Cmd>lua require('vscode').action('" .. command .. "')<Cr>"
end

keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap({ "n", "v" }, "E", "$", opts)
keymap({ "n", "v" }, "B", "^", opts)
-- -- JK光标移动多行
keymap({ "n", "v" }, "J", "7j", opts)
keymap({ "n", "v" }, "K", "7k", opts)
-- keymap({ "n", "v" }, "q", "<Esc>", opts)

keymap("n", "<leader>o", "o<Esc>", opts)
keymap("n", "<leader>O", "O<Esc>", opts)
-- -- 空格 + o/O 插入一行而不进入插入模式
--
-- -- leader + e 切换到 file tree
keymap("n", "<leader>e", codeAction("workbench.action.toggleSidebarVisibility"), opts)
-- -- HL切换标签页
keymap("n", "H", codeAction("workbench.action.previousEditorInGroup"), opts)
keymap("n", "L", codeAction("workbench.action.nextEditorInGroup"), opts)
-- --
-- 关闭当前tab/缓冲区
keymap("n", "<leader>bd", codeAction("workbench.action.closeActiveEditor"), opts)
keymap("n", "<leader>bl", codeAction("workbench.action.closeEditorsToTheRight"), opts)
keymap("n", "<leader>bh", codeAction("workbench.action.closeEditorsToTheLeft"), opts)

-- 纵向分屏
keymap("n", "<leader>wv", codeAction("workbench.action.splitEditor"), opts)

-- 横向分屏
keymap("n", "<leader>ws", codeAction("workbench.action.splitEditorOrthogonal"), opts)

-- 关闭当前编辑器
keymap("n", "<leader>wd", codeAction("workbench.action.closeActiveEditor"), opts)
keymap("n", "<leader>db", codeAction("editor.debug.action.toggleBreakpoint"))

-- 切换窗口
keymap("n", "<C-h>", codeAction("workbench.action.focusLeftGroup"), opts)
keymap("n", "<C-l>", codeAction("workbench.action.focusRightGroup"), opts)
keymap("n", "<C-k>", codeAction("workbench.action.focusAboveGroup"), opts)
keymap("n", "<C-j>", codeAction("workbench.action.focusBelowGroup"), opts)

keymap("n", "<leader>e", codeAction("workbench.action.toggleSidebarVisibility"), opts)
keymap("n", "W", codeAction("workbench.action.focusSideBar"), opts)
keymap("n", "<leader>a", codeAction("workbench.action.toggleActivityBarVisibility"), opts)

keymap("n", "gd", codeAction("editor.action.revealDefinition"), opts)
keymap("n", "gb", codeAction("workbench.action.navigateBack"), opts)

keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", opts)
