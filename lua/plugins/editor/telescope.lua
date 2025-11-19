return {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    opts = {
        defaults = {
            default_mappings = {
                n = {
                    ["?"] = require("telescope.actions").which_key,
                    ["q"] = require("telescope.actions").close,
                    ["<Tab>"] = require("telescope.actions").move_selection_next,
                    ["<S-Tab>"] = require("telescope.actions").move_selection_previous,
                    ["<Esc>"] = require("telescope.actions").close,
                    ["j"] = require("telescope.actions").move_selection_next,
                    ["k"] = require("telescope.actions").move_selection_previous,
                    ["<CR>"] = require("telescope.actions").select_default,
                    ["l"] = require("telescope.actions").select_default,
                    ["gg"] = require("telescope.actions").move_to_top,
                    ["G"] = require("telescope.actions").move_to_bottom,
                    ["<C-u>"] = require("telescope.actions").preview_scrolling_up,
                    ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
                    ["<PageUp>"] = require("telescope.actions").results_scrolling_up,
                    ["<PageDown>"] = require("telescope.actions").results_scrolling_down,
                    ["m"] = require("telescope.actions").center,
                    ["f"] = require("telescope.actions").to_fuzzy_refine,
                },
                i = {
                    ["<Tab>"] = require("telescope.actions").move_selection_next,
                    ["<S-Tab>"] = require("telescope.actions").move_selection_previous,
                    ["<CR>"] = require("telescope.actions").select_default,
                    ["<Up>"] = require("telescope.actions").move_selection_previous,
                    ["<Down>"] = require("telescope.actions").move_selection_next,
                    ["<C-u>"] = require("telescope.actions").preview_scrolling_up,
                    ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
                    ["<PageUp>"] = require("telescope.actions").results_scrolling_up,
                    ["<PageDown>"] = require("telescope.actions").results_scrolling_down,
                },
            },
        },
        pickers = {
            current_buffer_fuzzy_find = {
                sorting_strategy = "ascending",
            },
            buffers = {
                initial_mode = "normal",
                mappings = {
                    n = {
                        ["<Tab>"] = require("telescope.actions").toggle_selection
                            + require("telescope.actions").move_selection_next,
                        ["<S-Tab>"] = require("telescope.actions").toggle_selection
                            + require("telescope.actions").move_selection_previous,
                        ["d"] = require("telescope.actions").delete_buffer,
                        ["<leader>"] = require("telescope.actions").toggle_selection,
                        ["l"] = require("telescope.actions").select_default,
                        ["v"] = require("telescope.actions").select_vertical,
                        ["s"] = require("telescope.actions").select_horizontal,
                    },
                },
                dynamic_preview_title = true,
                layout_config = {
                    preview_width = 0.6,
                },
            },
            marks = {
                initial_mode = "normal",
                mappings = {
                    n = {
                        ["d"] = require("telescope.actions").delete_mark,
                        ["<leader>"] = require("telescope.actions").toggle_selection,
                        ["l"] = require("telescope.actions").select_default,
                        ["v"] = require("telescope.actions").select_vertical,
                        ["s"] = require("telescope.actions").select_horizontal,
                    },
                },
                layout_config = {
                    preview_width = 0.6,
                },
            },
            find_files = {
                file_ignore_patterns = { "node_modules", "target/" },
            },
            live_grep = {
                file_ignore_patterns = { "node_modules", "target/" },
            },
            grep_string = {
                file_ignore_patterns = { "node_modules", "target/" },
            },
            lsp_document_symbols = {
                layout_config = {
                    preview_width = 0.7,
                },
            },
            lsp_dynamic_workspace_symbols = {
                layout_config = {
                    preview_width = 0.6,
                },
            },
            oldfiles = {
                initial_mode = "normal",
            },
            jumplist = {
                initial_mode = "normal",
            },
            colorscheme = {
                initial_mode = "normal",
            },
            registers = {
                initial_mode = "normal",
            },
        },
    },
    keys = function()
        return {
            {
                "?",
                function()
                    require("telescope.builtin").current_buffer_fuzzy_find()
                end,
                desc = "search in current buffer",
            },
            {
                "<leader>/",
                function()
                    require("telescope.builtin").live_grep()
                end,
                desc = "Live Grep",
            },
            {
                "<leader>s:",
                function()
                    require("telescope.builtin").command_history()
                end,
                desc = "Command History",
            },
            {
                "<leader><space>",
                function()
                    require("telescope.builtin").find_files({
                        hidden = true,
                        no_ignore = true,
                    })
                end,
                desc = "Find Files (Root Dir)",
            },
            {
                "<leader>sw",
                function()
                    require("telescope.builtin").grep_string()
                end,
                mode = { "n", "v" },
                desc = "search current word",
            },
            {
                "<leader>b",
                function()
                    require("telescope.builtin").buffers({
                        sort_mru = true, -- 按最近使用排序
                        sort_lastused = true, -- 当前 buffer 和上一个 buffer 排前两个
                        ignore_current_buffer = true, -- 忽略当前buffer
                    })
                end,
                desc = "Buffers",
            },
            {
                "<leader>sa",
                function()
                    require("telescope.builtin").autocommands()
                end,
                desc = "Auto Commands",
            },
            {
                "<leader>sc",
                function()
                    require("telescope.builtin").commands()
                end,
                desc = "Commands",
            },
            {
                "<leader>sk",
                function()
                    require("telescope.builtin").keymaps()
                end,
                desc = "Keymaps",
            },
            {
                "<leader>sf",
                function()
                    require("telescope.builtin").filetypes()
                end,
                desc = "Change Current Filetypes",
            },
            {
                "<leader>sm",
                function()
                    require("telescope.builtin").marks()
                end,
                desc = "Marks",
            },
            {
                "<leader>so",
                function()
                    require("telescope.builtin").vim_options()
                end,
                desc = "Options",
            },
            {
                "<leader>sh",
                function()
                    require("telescope.builtin").oldfiles()
                end,
                desc = "History Files",
            },
            {
                "<leader>sr",
                function()
                    require("telescope.builtin").registers()
                end,
                desc = "registers",
            },
            {
                "<leader>h",
                function()
                    require("telescope.builtin").jumplist({
                        trim_text = true,
                    })
                end,
                desc = "Jump List",
            },
            {
                "<leader>sC",
                function()
                    require("telescope.builtin").colorscheme({ enable_preview = true, ignore_builtins = true })
                end,
                desc = "Colorscheme",
            },
            {
                "<leader>ss",
                function()
                    require("telescope.builtin").lsp_document_symbols({ symbol_width = 40 })
                end,
                desc = "Symbol",
            },
            {
                "<leader>sS",
                function()
                    require("telescope.builtin").lsp_dynamic_workspace_symbols({})
                end,
                desc = "Symbol (Workspace)",
            },
        }
    end,
}
