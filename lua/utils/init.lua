-- 工具函数模块
-- 包含原有的 utils 和从 LazyVim 迁移的工具函数

local M = {}

-- 延迟加载所有子模块
setmetatable(M, {
  __index = function(t, k)
    -- 尝试加载自定义工具模块
    local ok, module = pcall(require, "utils." .. k)
    if ok then
      rawset(t, k, module)
      return module
    end
    -- 回退到 lazy.nvim 的工具函数
    local LazyUtil = require("lazy.core.util")
    if LazyUtil[k] then
      return LazyUtil[k]
    end
  end,
})

--- 检查是否为 Windows 系统
function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

--- 获取插件信息
---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

--- 获取插件路径
---@param name string
---@param path string?
function M.get_plugin_path(name, path)
  local plugin = M.get_plugin(name)
  path = path and "/" .. path or ""
  return plugin and (plugin.dir .. path)
end

--- 检查插件是否已安装
---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

--- 在 VeryLazy 事件时执行函数
---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

--- 获取插件的选项
---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

--- 通知函数（带默认标题）
for _, level in ipairs({ "info", "warn", "error" }) do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or "Nvim"
    local LazyUtil = require("lazy.core.util")
    return LazyUtil[level](msg, opts)
  end
end

--- 状态栏列渲染
--- 使用 snacks.statuscolumn 如果可用
function M.statuscolumn()
  return package.loaded.snacks and require("snacks.statuscolumn").get() or ""
end

--- 规范化路径
---@param path string
---@return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.uv.os_homedir()
    if home:sub(-1) == "\\" or home:sub(-1) == "/" then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

--- 安全调用函数，捕获错误
---@param fn function
---@param opts? {msg?:string, on_error?:fun(msg)}
function M.try(fn, opts)
  opts = opts or {}
  local ok, err = pcall(fn)
  if not ok then
    local msg = opts.msg and (opts.msg .. "\n\n" .. err) or err
    if opts.on_error then
      opts.on_error(msg)
    else
      M.error(msg)
    end
  end
  return ok
end

-- 原有的 icons
M.icons = {
    misc = {
        dots                = "󰇘",
    },
    ft = {
        octo                = " ",
        gh                  = " ",
        ["markdown.gh"]     = " ",
    },
    dap = {
        Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint          = " ",
        BreakpointCondition = " ",
        BreakpointRejected  = { " ", "DiagnosticError" },
        LogPoint            = ".>",
    },
    diagnostics = {
        Error               = " ",
        Warn                = " ",
        Hint                = " ",
        Info                = " ",
    },
    git = {
        added               = " ",
        modified            = " ",
        removed             = " ",
    },
    kinds                   = {
        Array               = " ",
        Boolean             = "󰨙 ",
        Class               = " ",
        Codeium             = "󰘦 ",
        Color               = " ",
        Control             = " ",
        Collapsed           = " ",
        Constant            = "󰏿 ",
        Constructor         = " ",
        Copilot             = " ",
        Enum                = " ",
        EnumMember          = " ",
        Event               = " ",
        Field               = " ",
        File                = " ",
        Folder              = " ",
        Function            = "󰊕 ",
        Interface           = " ",
        Key                 = " ",
        Keyword             = " ",
        Method              = "󰊕 ",
        Module              = " ",
        Namespace           = "󰦮 ",
        Null                = " ",
        Number              = "󰎠 ",
        Object              = " ",
        Operator            = " ",
        Package             = " ",
        Property            = " ",
        Reference           = " ",
        Snippet             = "󱄽 ",
        String              = " ",
        Struct              = "󰆼 ",
        Supermaven          = " ",
        TabNine             = "󰏚 ",
        Text                = " ",
        TypeParameter       = " ",
        Unit                = " ",
        Value               = " ",
        Variable            = "󰀫 ",
    },
}

return M
