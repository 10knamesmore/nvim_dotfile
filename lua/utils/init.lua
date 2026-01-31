-- 工具函数模块

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
    -- 回退到 lazy.nvim 的工具函数（如果存在）
    local ok2, LazyUtil = pcall(require, "lazy.core.util")
    if ok2 and LazyUtil[k] then
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

--- 性能追踪
local track_stack = {}
function M.track(event)
  if event then
    track_stack[#track_stack + 1] = event
  elseif #track_stack > 0 then
    table.remove(track_stack)
  end
end

--- 在插件加载后执行回调
---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

--- 延迟通知直到 vim.notify 被替换
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig
    end
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- 等待 vim.notify 被替换
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- 或者 500ms 后重放
  timer:start(500, 0, replay)
end

--- 检查插件是否已加载
---@param name string
---@return boolean
function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

--- 设置默认选项值（如果尚未设置）
--- 返回是否成功设置（true = 设置了新值，false = 已有值）
---@param option string
---@param value any
---@return boolean
function M.set_default(option, value)
  local current = vim.api.nvim_get_option_value(option, { scope = "local" })
  if current == "" or current == nil then
    vim.api.nvim_set_option_value(option, value, { scope = "local" })
    return true
  end
  return false
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
