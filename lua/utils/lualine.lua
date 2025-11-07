---@class util.lualine
local M = {}

-- 根据 传入的status, 设置 icon的 hlgroup
---@param icon string
---@param status fun(): nil|"ok"|"error"|"pending"
function M.status(icon, status)
    local colors = {
        ok = "Special",
        error = "DiagnosticError",
        pending = "DiagnosticWarn",
    }
    return {
        function()
            return icon
        end,
        cond = function()
            return status() ~= nil
        end,
        color = function()
            return { fg = Snacks.util.color(colors[status()] or colors.ok) }
        end,
    }
end

---@param component any
---@param text string
---@param hl_group? string
---@return string
function M.format(component, text, hl_group)
    text = text:gsub("%%", "%%%%")
    if not hl_group or hl_group == "" then
        return text
    end
    ---@type table<string, string>
    component.hl_cache = component.hl_cache or {}
    local lualine_hl_group = component.hl_cache[hl_group]
    if not lualine_hl_group then
        local utils = require("lualine.utils.utils")
        ---@type string[]
        local gui = vim.tbl_filter(function(x)
            return x
        end, {
            utils.extract_highlight_colors(hl_group, "bold") and "bold",
            utils.extract_highlight_colors(hl_group, "italic") and "italic",
        })

        lualine_hl_group = component:create_hl({
            fg = utils.extract_highlight_colors(hl_group, "fg"),
            gui = #gui > 0 and table.concat(gui, ",") or nil,
        }, "LV_" .. hl_group) --[[@as string]]
        component.hl_cache[hl_group] = lualine_hl_group
    end
    return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

-- 将路径中的 `~` 替换为用户主目录，并将反斜杠转换为斜杠，最后去除末尾多余的斜杠。
function M.norm(path)
    if path:sub(1, 1) == "~" then
        local home = vim.uv.os_homedir()
        if home and (home:sub(-1) == "\\" or home:sub(-1) == "/") then
            home = home:sub(1, -2)
        end
        path = home .. path:sub(2)
    end
    path = path:gsub("\\", "/"):gsub("/+", "/")
    return path:sub(-1) == "/" and path:sub(1, -2) or path
end

---@param opts? {relative: "cwd"|"root", modified_hl: string?, directory_hl: string?, filename_hl: string?, modified_sign: string?, readonly_icon: string?, length: number?}
function M.pretty_path(opts)
    opts = vim.tbl_extend("force", {
        relative = "cwd",
        modified_hl = "MatchParen",
        directory_hl = "",
        filename_hl = "Bold",
        modified_sign = "",
        readonly_icon = " 󰌾 ",
        length = 3,
    }, opts or {})

    return function(self)
        local path = vim.fn.expand("%:p") --[[@as string]]

        if path == "" then
            return ""
        end

        path = M.norm(path)
        local root = utils.path.get_root({ normalize = true })
        local cwd = utils.path.cwd()

        -- original path is preserved to provide user with expected result of pretty_path, not a normalized one,
        -- which might be confusing
        local norm_path = path

        if opts.relative == "cwd" and norm_path:find(cwd, 1, true) == 1 then
            path = path:sub(#cwd + 2)
        elseif norm_path:find(root, 1, true) == 1 then
            path = path:sub(#root + 2)
        end

        local sep = package.config:sub(1, 1)
        local parts = vim.split(path, "[\\/]")

        if opts.length == 0 then
            parts = parts
        elseif #parts > opts.length then
            parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
        end

        if opts.modified_hl and vim.bo.modified then
            parts[#parts] = parts[#parts] .. opts.modified_sign
            parts[#parts] = M.format(self, parts[#parts], opts.modified_hl)
        else
            parts[#parts] = M.format(self, parts[#parts], opts.filename_hl)
        end

        local dir = ""
        if #parts > 1 then
            dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
            dir = M.format(self, dir .. sep, opts.directory_hl)
        end

        local readonly = ""
        if vim.bo.readonly then
            readonly = M.format(self, opts.readonly_icon, opts.modified_hl)
        end
        return dir .. parts[#parts] .. readonly
    end
end

function M.root_dir()
    -- 组件选项,用于控制不同目录关系下的显示
    local opts = {
        color = function()
            return { fg = vim.api.nvim_get_hl(0, { name = "Special", link = false, create = false }) }
        end,
    }

    -- 获取根目录与 cwd 的关系,返回目录名或 nil
    local function get()
        local cwd = utils.path.cwd()
        local root = utils.path.get_root({ normalize = true })
        local name = vim.fs.basename(root)

        if root == cwd then
            -- 根目录即为 cwd
            return name
        elseif root and cwd and root:find(cwd, 1, true) == 1 then
            -- 根目录是 cwd 的子目录
            return name
        elseif root and cwd and cwd:find(root, 1, true) == 1 then
            -- 根目录是 cwd 的父目录
            return name
        else
            -- 根目录与 cwd 无关
            return name
        end
    end

    -- 返回 lualine 组件配置
    return {
        function()
            return "󱉭  " .. get()
        end,
        cond = function()
            return true
        end,
        color = opts.color,
    }
end

return M
