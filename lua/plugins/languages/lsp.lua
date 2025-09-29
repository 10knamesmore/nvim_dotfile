return {
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "lua-language-server",
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)

            local mr = require("mason-registry")
            local function ensure_installed()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then
                        p:install()
                    end
                end
            end
            if mr.refresh then
                mr.refresh(ensure_installed)
            else
                ensure_installed()
            end
        end,
    },
    -- LSP keymaps
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        opts = function()
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            -- change a keymap
            keys[#keys + 1] = { "K", "7gk" }
        end,
    },
}
