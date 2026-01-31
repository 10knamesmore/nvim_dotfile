-- Terminal 工具模块
-- 提供终端辅助功能

---@class util.terminal
local M = {}

--- 在浮动窗口中打开终端
---@param cmd? string|string[]
---@param opts? table
function M.open(cmd, opts)
  opts = opts or {}
  cmd = cmd or vim.o.shell
  
  if package.loaded.snacks then
    Snacks.terminal(cmd, opts)
  else
    -- 简单的 fallback
    vim.cmd("terminal " .. (type(cmd) == "table" and table.concat(cmd, " ") or cmd))
  end
end

return M
