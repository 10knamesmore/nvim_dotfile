-- Pick 工具模块
-- 来源: LazyVim util/pick.lua  
-- 提供 picker (telescope/fzf) 辅助功能

---@class util.pick
---@overload fun(command:string, opts?:table): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class Picker
---@field name string
---@field open fun(command:string, opts?:table)
---@field commands table<string, string>

---@type Picker?
M.picker = nil

--- 注册 picker
---@param picker Picker
function M.register(picker)
  if vim.v.vim_did_enter == 1 then
    return true
  end

  if M.picker and M.picker.name ~= picker.name then
    local Util = require("utils")
    Util.warn(
      "`pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`"
    )
    return false
  end
  M.picker = picker
  return true
end

--- 打开 picker
---@param command? string
---@param opts? table
function M.open(command, opts)
  if not M.picker then
    local Util = require("utils")
    return Util.error("pick: picker not set")
  end

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  -- 处理 root 选项
  if opts.root ~= false and (opts.cwd == nil and opts.root ~= false) then
    local Util = require("utils")
    opts.cwd = Util.root()
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

--- 包装 picker 命令
---@param command string
---@param opts? table
---@return fun()
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    M.open(command, vim.deepcopy(opts))
  end
end

--- 配置文件选择器
M.config_files = function()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
