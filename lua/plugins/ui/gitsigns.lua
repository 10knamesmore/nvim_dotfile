return {
    "lewis6991/gitsigns.nvim",
    opts = function()
        vim.keymap.set("n", "<leader>ug", function()
            require("gitsigns").toggle_deleted()
            require("gitsigns").toggle_linehl()
            require("gitsigns").toggle_word_diff()
        end, { noremap = true, desc = "Toggle Diff" })
        local opts = {
            signs_staged_enable = true,
            signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`
            numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                follow_files = true,
            },
            on_attach = function(buffer)
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
                end

                -- stylua: ignore start
                map("n", "]h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    require("gitsigns").nav_hunk("next")
                end
                end, "Next Hunk")
                map("n", "[h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    require("gitsigns").nav_hunk("prev")
                end
                end, "Prev Hunk")
                map("n", "]H", function() require("gitsigns").nav_hunk("last") end, "Last Hunk")
                map("n", "[H", function() require("gitsigns").nav_hunk("first") end, "First Hunk")
                map("n", "<leader>gh",
                    require("gitsigns").preview_hunk_inline
                , "Word Diff")
            end,
        }
        return opts
    end,
}
