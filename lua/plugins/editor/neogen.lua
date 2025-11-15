-- 为函数添加注释
-- <leader>cn
return {
    "danymat/neogen",
    cmd = "Neogen",
    keys = {
        {
            "<leader>cn",
            function()
                require("neogen").generate()
            end,
            desc = "生成注释 (Neogen)",
        },
    },
    opts = function(_, opts)
        if opts.snippet_engine ~= nil then
            return
        end

        local map = {
            ["LuaSnip"] = "luasnip",
            ["nvim-snippy"] = "snippy",
            ["vim-vsnip"] = "vsnip",
        }

        for plugin, engine in pairs(map) do
            if utils.plugins.has(plugin) then
                opts.snippet_engine = engine
                return
            end
        end

        if vim.snippet then
            opts.snippet_engine = "nvim"
        end
    end,
}
