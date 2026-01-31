-- Inject 工具模块
-- 提供函数注入和upvalue操作

---@class util.inject
local M = {}

--- 包装函数并注入参数检查
---@generic F: function
---@param fn F
---@param wrapper fun(...): boolean?
---@return F
function M.args(fn, wrapper)
  return function(...)
    if wrapper(...) == false then
      return
    end
    return fn(...)
  end
end

--- 获取函数的 upvalue
function M.get_upvalue(func, name)
  local i = 1
  while true do
    local n, v = debug.getupvalue(func, i)
    if not n then
      break
    end
    if n == name then
      return v
    end
    i = i + 1
  end
end

--- 设置函数的 upvalue
function M.set_upvalue(func, name, value)
  local i = 1
  while true do
    local n = debug.getupvalue(func, i)
    if not n then
      break
    end
    if n == name then
      debug.setupvalue(func, i, value)
      return
    end
    i = i + 1
  end
  local Util = require("utils")
  Util.error("upvalue not found: " .. name)
end

return M
