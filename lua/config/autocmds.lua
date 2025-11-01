local cmd = vim.api.nvim_create_autocmd

-- sh 支持
cmd({ "BufRead" }, {
    pattern = { ".alias", ".zshfunc" },
    callback = function()
        vim.bo.filetype = "sh"
    end,
})

-- dockerfile 支持
cmd({ "BufRead" }, {
    pattern = "Dockerfile*",
    callback = function()
        vim.bo.filetype = "dockerfile"
    end,
})

-- 在 csv 文件中打开spell检查
cmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.csv",
    callback = function()
        vim.opt_local.wrap = false
    end,
})

-- 在markdown中关闭diagnostic
cmd("filetype", {
    pattern = "markdown",
    callback = function()
        vim.diagnostic.enable(false)
    end,
})

-- 禁用lazivim自带的spell检查
vim.api.nvim_clear_autocmds({ group = "lazyvim_wrap_spell" })
