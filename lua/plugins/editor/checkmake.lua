---@type checkmate.Config
local _DEFAULTS = {
    enabled = true,
    notify = true,
    files = { "todo", "TODO", "*.todo*" }, -- matches TODO, TODO.md, .todo.md
    log = {
        level = "info",
        use_file = false,
        use_buffer = false,
    },
    -- Default keymappings
    keys = {
        ["<leader>Tt"] = "toggle", -- Toggle todo item
        ["<leader>Tc"] = "check", -- Set todo item as checked (done)
        ["<leader>Tu"] = "uncheck", -- Set todo item as unchecked (not done)
        ["<leader>Tn"] = "create", -- Create todo item
        ["<leader>TR"] = "remove_all_metadata", -- Remove all metadata from a todo item
        ["<leader>Ta"] = "archive", -- Archive checked/completed todo items (move to bottom section)
    },
    default_list_marker = "-",
    todo_markers = {
        unchecked = "□",
        checked = "✔",
    },
    style = {},
    todo_action_depth = 1, --  Depth within a todo item's hierachy from which actions (e.g. toggle) will act on the parent todo item
    enter_insert_after_new = true, -- Should enter INSERT mode after :CheckmateCreate (new todo)
    smart_toggle = {
        enabled = true,
        check_down = "direct_children",
        uncheck_down = "none",
        check_up = "direct_children",
        uncheck_up = "direct_children",
    },
    show_todo_count = true,
    todo_count_position = "eol",
    todo_count_recursive = true,
    use_metadata_keymaps = true,
    metadata = {
        -- Example: A @priority tag that has dynamic color based on the priority value
        priority = {
            style = function(_value)
                local value = _value:lower()
                if value == "high" then
                    return { fg = "#ff5555", bold = true }
                elseif value == "medium" then
                    return { fg = "#ffb86c" }
                elseif value == "low" then
                    return { fg = "#8be9fd" }
                else -- fallback
                    return { fg = "#8be9fd" }
                end
            end,
            get_value = function()
                return "medium" -- Default priority
            end,
            key = "<leader>Tp",
            sort_order = 10,
            jump_to_on_insert = "value",
            select_on_insert = true,
        },
        -- Example: A @started tag that uses a default date/time string when added
        started = {
            aliases = { "init" },
            style = { fg = "#9fd6d5" },
            get_value = function()
                return tostring(os.date("%m/%d/%y %H:%M"))
            end,
            key = "<leader>Ts",
            sort_order = 20,
        },
        -- Example: A @done tag that also sets the todo item state when it is added and removed
        done = {
            aliases = { "completed", "finished" },
            style = { fg = "#96de7a" },
            get_value = function()
                return tostring(os.date("%m/%d/%y %H:%M"))
            end,
            key = "<leader>Td",
            on_add = function(todo_item)
                require("checkmate").set_todo_item(todo_item, "checked")
            end,
            on_remove = function(todo_item)
                require("checkmate").set_todo_item(todo_item, "unchecked")
            end,
            sort_order = 30,
        },
    },
    archive = {
        heading = {
            title = "Archive",
            level = 2, -- e.g. ##
        },
        parent_spacing = 0, -- no extra lines between archived todos
    },
    linter = {
        enabled = true,
    },
}

return {
    "bngarren/checkmate.nvim",
    ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
    opts = {},
}
