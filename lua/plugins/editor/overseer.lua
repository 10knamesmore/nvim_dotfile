--- 后台任务管理器
return {
    {
        "catppuccin",
        optional = true,
        opts = {
            integrations = { overseer = true },
        },
    },
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerSaveBundle",
            "OverseerLoadBundle",
            "OverseerDeleteBundle",
            "OverseerRunCmd",
            "OverseerRun",
            "OverseerInfo",
            "OverseerBuild",
            "OverseerQuickAction",
            "OverseerTaskAction",
            "OverseerClearCache",
        },
        opts = {
            dap = false,
            task_list = {
                bindings = {
                    ["<C-h>"] = false,
                    ["<C-j>"] = false,
                    ["<C-k>"] = false,
                    ["<C-l>"] = false,
                },
                max_width = { 120, 0.2 },
                min_width = 80,

                max_height = { 50, 0.2 },
                min_height = 30,
            },
            form = {
                win_opts = {
                    winblend = 0,
                },
            },
            confirm = {
                win_opts = {
                    winblend = 0,
                },
            },
            task_win = {
                win_opts = {
                    winblend = 0,
                },
            },
        },
    -- stylua: ignore
    keys = {
      { "<leader>tw", "<cmd>OverseerToggle<cr>",      desc = "Task list" },
      { "<leader>to", "<cmd>OverseerRun<cr>",         desc = "Run task" },
      { "<leader>tq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
      { "<leader>ti", "<cmd>OverseerInfo<cr>",        desc = "Overseer Info" },
      { "<leader>tb", "<cmd>OverseerBuild<cr>",       desc = "Task builder" },
      { "<leader>tt", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },
      { "<leader>tc", "<cmd>OverseerClearCache<cr>",  desc = "Clear cache" },
    },
    },
    {
        "folke/which-key.nvim",
        optional = true,
        opts = {
            spec = {
                { "<leader>t", group = "overseer (background [T]ask)" },
            },
        },
    },
    {
        "nvim-neotest/neotest",
        optional = true,
        opts = function(_, opts)
            opts = opts or {}
            opts.consumers = opts.consumers or {}
            opts.consumers.overseer = require("neotest.consumers.overseer")
        end,
    },
    {
        "mfussenegger/nvim-dap",
        optional = true,
        opts = function()
            require("overseer").enable_dap()
        end,
    },
}
