-- JSON 工具模块
-- 提供 JSON 处理功能

---@class util.json
local M = {}

--- 读取 JSON 文件
---@param file string
---@return table?
function M.read(file)
  local ok, data = pcall(vim.fn.readfile, file)
  if not ok then
    return nil
  end
  local ok2, json = pcall(vim.fn.json_decode, table.concat(data, "\n"))
  if not ok2 then
    return nil
  end
  return json
end

--- 写入 JSON 文件
---@param file string
---@param data table
function M.write(file, data)
  local json = vim.fn.json_encode(data)
  vim.fn.writefile(vim.split(json, "\n"), file)
end

return M
