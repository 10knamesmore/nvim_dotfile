-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local function opts(desc)
    local opts = { noremap = true, silent = true }

    if desc then
        opts.desc = desc
    end
    return opts
end

-- 有些keymaps需要等待LazyVim和Snacks
-- Hack 现在是推迟到
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
        LazyVim.format.snacks_toggle():map("<leader>uf")
        LazyVim.format.snacks_toggle(true):map("<leader>uF")
        --
        -- Clear search and stop snippet on escape
        map({ "i", "n", "s" }, "<esc>", function()
            vim.cmd("noh")
            LazyVim.cmp.actions.snippet_stop()
            return "<esc>"
        end, { expr = true, desc = "Escape and Clear hlsearch" })

        -- lazygit
        if vim.fn.executable("lazygit") == 1 then
            map("n", "<leader>gg", function()
                Snacks.lazygit({ cwd = LazyVim.root.git() })
            end, { desc = "Lazygit (Root Dir)" })
            map("n", "<leader>gG", function()
                Snacks.lazygit()
            end, { desc = "Lazygit (cwd)" })
        end

        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
            .option(
                "conceallevel",
                { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }
            )
            :map("<leader>uc")
        Snacks.toggle
            .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
            :map("<leader>uA")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.dim():map("<leader>uD")
        Snacks.toggle.animate():map("<leader>ua")
        Snacks.toggle.indent():map("<leader>ug")
        -- Snacks.toggle.scroll():map("<leader>uS") 用mini-animation替代了
        Snacks.toggle.profiler():map("<leader>dpp")
        Snacks.toggle.profiler_highlights():map("<leader>dph")

        map("n", "<leader>bd", function()
            Snacks.bufdelete()
        end, { desc = "Delete Buffer" })

        map("n", "<leader>bo", function()
            Snacks.bufdelete.other()
        end, { desc = "Delete Other Buffers" })

        if vim.lsp.inlay_hint then
            Snacks.toggle.inlay_hints():map("<leader>uh")
        end

        map("n", "<leader>gl", function()
            Snacks.picker.git_log()
        end, { desc = "Git Log (cwd)" })

        map("n", "<leader>gd", function()
            Snacks.picker.git_diff()
        end, { desc = "Git Diff" })

        map("n", "<leader>gf", function()
            Snacks.picker.git_log_file()
        end, { desc = "Git Current File History" })

        map({ "n", "x" }, "<localleader>r", function()
            Snacks.debug.run()
        end, { desc = "Run Lua" })

        map({ "n", "x" }, "<leader>gB", function()
            Snacks.gitbrowse()
        end, { desc = "git open remote" })

        -- highlightgroup under cursor
        map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

        -- treesitter inspect tree
        map("n", "<leader>uI", function()
            vim.treesitter.inspect_tree()
            vim.api.nvim_input("I")
        end, { desc = "Inspect Tree" })

        map({ "n", "t" }, "<c-/>", function()
            Snacks.terminal(nil, { cwd = LazyVim.root() })
        end, { desc = "Terminal (Root Dir)" })
    end,
})

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- 重绘
map(
    "n",
    "<leader>ur",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- n总是向前搜索，N总是向后搜索，并且展开折叠
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- 注释
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- diagnostic
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-----------------------------------------------------------
map("n", "<Space>", "", opts())
map({ "n", "v" }, "q", "", opts())

-- 用E和B跳到行首行尾
map({ "n", "v" }, "E", "$", opts())
map({ "n", "v" }, "B", "^", opts())

-- 模式切换
-- -- 插入模式下jk,kj退出
map("i", "jk", "<Esc>", opts())
map("i", "kj", "<Esc>", opts())

-- 移动光标
map("n", "gb", "<C-o>", opts("LSP跳转返回"))
map("n", "<C-o>", "<C-i>", opts("LSP跳转返回"))
map("n", "<C-i>", "<C-o>", opts("LSP跳转返回"))
-- -- JK光标移动多行
map({ "n", "v" }, "J", "7gj", opts())
map({ "n", "v" }, "K", "7gk", opts())
-- -- 空格 + o/O 插入一行而不进入插入模式
map("n", "<leader>o", "o<Esc>", opts())
map("n", "<leader>O", "O<Esc>", opts())
map("n", "gm", "'", opts("跳转到标签"))
-- 目前让 <> 什么都不做
map({ "n", "v" }, "<", "<Nop>")
map({ "n", "v" }, ">", "<Nop>")

-- 移动__窗口
-- -- 大写 W 切换窗口焦点
map("n", "W", "<C-w>w", opts())
-- --  左右方向键切换标签页,上下方向键什么都不干
map("n", "<Left>", ":bp<CR>", opts())
map("n", "<Right>", ":bn<CR>", opts())
map("n", "<Up>", "", opts())
map("n", "<Down>", "", opts())

-- -- -- -- -- -- 插件相关 -- -- -- -- -- --
map("n", "?", ":Telescope current_buffer_fuzzy_find<Cr>", opts("文件内查找"))
map("n", "<leader>sB", ":Telescope buffers sort_mru=true sort_lastused=true<Cr>", opts("切换Buffer"))
