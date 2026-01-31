-- Plugin 工具模块  
-- 提供插件管理相关的辅助功能

---@class util.plugin
local M = {}

-- 这些是原本 LazyFile 事件对应的原始事件
-- 已在所有插件配置中直接使用，不再需要自定义事件
M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

--- 设置插件工具（已不需要注册自定义事件）
function M.setup()
  -- LazyFile 已被移除，所有插件直接使用原始事件
end

return M
