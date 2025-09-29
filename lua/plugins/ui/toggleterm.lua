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
        },
    },
}
