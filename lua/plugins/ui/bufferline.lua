-- 编辑器上方的buffer
return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
        -- { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
        { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "删除右侧的 buffer" },
        { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "删除左侧的 buffer" },
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        -- { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        -- { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
        { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    },
    opts = {
        options = {
            close_command = function(n)
                Snacks.bufdelete(n)
            end,
            right_mouse_command = function(n)
                -- Snacks.bufdelete(n)
            end,
            diagnostics = "nvim_lsp",
            always_show_bufferline = false,
            diagnostics_indicator = function(_, _, diag)
                local icons = LazyVim.config.icons.diagnostics
                local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                    .. (diag.warning and icons.Warn .. diag.warning or "")
                return vim.trim(ret)
            end,
            indicator = {
                icon = "▎", -- this should be omitted if indicator style is not 'icon'
                style = "icon",
            },
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    highlight = "Directory",
                    text_align = "left",
                },
                {
                    filetype = "snacks_layout_box",
                },
            },
            hover = {
                enabled = true,
                delay = 200,
                reveal = { "close" },
            },
            -- separator_style = "slant" | "slope" | "thick" | "thin" | { "any", "any" },
            separator_style = "slope",
            ---@param opts bufferline.IconFetcherOpts
            get_element_icon = function(opts)
                return LazyVim.config.icons.ft[opts.filetype]
            end,
            sort_by = function(buffer_a, buffer_b)
                -- -- add custom logic
                -- local modified_a = vim.fn.getftime(buffer_a.path)
                -- local modified_b = vim.fn.getftime(buffer_b.path)
                -- return modified_a > modified_b
                return buffer_a.id < buffer_b.id
            end,
        },
    },
    config = function(_, opts)
        require("bufferline").setup(opts)
        -- Fix bufferline when restoring a session
        vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
            callback = function()
                vim.schedule(function()
                    pcall(nvim_bufferline)
                end)
            end,
        })
    end,
}
