return {
    {
        "cordx56/rustowl",
        version = "*", -- Latest stable version
        build = "cargo binstall rustowl",
        lazy = false, -- This plugin is already lazy
        opts = {
            auto_attach = false,
            highlight_style = "underline",
            client = {
                on_attach = function(_, buffer)
                    vim.keymap.set("n", "<leader>uo", function()
                        require("rustowl").toggle(buffer)
                    end, { buffer = buffer, desc = "Toggle RustOwl" })
                end,
            },
        },
    },
}
