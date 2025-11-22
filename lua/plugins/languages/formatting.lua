-- 格式化插件配置
return {
    "stevearc/conform.nvim",

    dependencies = { "mason.nvim" },

    lazy = true,

    cmd = "ConformInfo",

    opts = {
        -- 不同文件类型对应的格式化器设置
        formatters_by_ft = {
            lua = { "stylua" },
            fish = { "fish_indent" },
            sh = { "shfmt" },
        },
    },

    keys = function()
        return {
            {
                "<leader>cf",
                function()
                    require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
                end,
                mode = { "n", "x" },
                desc = "Format Injected Langs",
            },
        }
    end,
}
