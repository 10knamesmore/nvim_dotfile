return {
    -- amongst your other plugins
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = {
            dir = vim.fn.getcwd(),
            direction = "float",
            open_mapping = [[<C-\>]],
            terminal_mapping = true,
            insert_mapping = true,
            auto_chdir = true,
            float_opts = {
                -- 边框样式：可以选择 single、double、shadow 或 curved
                border = "rounded",
            },
            vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true }),
            vim.keymap.set("n", "<localleader><localleader>", function()
                -- 获取当前缓冲区所在目录或工作目录
                local term = require("toggleterm.terminal").Terminal:new({
                    direction = "float",
                    display_name = vim.fn.getcwd(),

                    on_open = function(term)
                        local cwd = vim.fn.getcwd()
                        local cmdline = term.cmd or ""
                        local name

                        if cmdline ~= "" then
                            name = cmdline
                        else
                            name = cwd
                        end
                        term.display_name = name
                    end,
                })
                term:toggle()
            end, { desc = "new Terminal" }),
            vim.keymap.set("n", "<localleader>s", "<cmd>TermSelect<CR>", { desc = "choose Terminal" }),
            vim.keymap.set("n", "<localleader>n", "<cmd>ToggleTermSetName<CR>", { desc = "set Terminal Name" }),
        },
    },
}
