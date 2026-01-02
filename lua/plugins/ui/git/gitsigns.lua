return {
    "lewis6991/gitsigns.nvim",
    opts = function()
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

                map("n", "<leader>gd", function()
                    if vim.wo.diff then
                        vim.cmd("diffoff!")
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                            local name = vim.api.nvim_buf_get_name(buf)
                            if name:match("^gitsigns:") then
                                vim.api.nvim_buf_delete(buf, { force = true })
                            end
                        end
                    else
                        local bufnr = vim.api.nvim_get_current_buf()
                        local hunks = require("gitsigns").get_hunks(bufnr)
                        if vim.tbl_isempty(hunks) then
                            vim.notify("No changes to diff", vim.log.levels.INFO)
                            return
                        end
                        require("gitsigns").diffthis()
                    end
                end, "Diff This")

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

                map({ "n", "v" }, "<leader>ga", function()
                    if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
                        local start_line = vim.fn.line("v")
                        local end_line = vim.fn.line(".")
                        if start_line > end_line then
                            start_line, end_line = end_line, start_line
                        end
                        require("gitsigns").stage_hunk({ start_line, end_line })
                    else
                        require("gitsigns").stage_hunk()
                    end
                end, "Stage Hunk")

                map("n", "]H", function()
                    require("gitsigns").nav_hunk("last")
                end, "Last Hunk")

                map("n", "[H", function()
                    require("gitsigns").nav_hunk("first")
                end, "First Hunk")
            end,
        }

        vim.keymap.del("n", "<leader>uG")
        return opts
    end,
}
