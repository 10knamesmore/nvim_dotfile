-- LazyVim 兼容层
-- 提供 _G.LazyVim API 以保持向后兼容性
-- 实际功能由 utils 模块提供

local Util = require("utils")

---@class LazyVim
local LazyVim = {}

-- 格式化相关
LazyVim.format = Util.format

-- 根目录检测
LazyVim.root = Util.root

-- UI 相关
LazyVim.statuscolumn = Util.statuscolumn

-- 通知函数
LazyVim.info = Util.info
LazyVim.warn = Util.warn
LazyVim.error = Util.error

-- 插件相关
LazyVim.has = Util.has
LazyVim.opts = Util.opts
LazyVim.get_plugin = Util.get_plugin
LazyVim.get_plugin_path = Util.get_plugin_path

-- 工具函数
LazyVim.norm = Util.norm
LazyVim.try = Util.try
LazyVim.is_win = Util.is_win
LazyVim.on_very_lazy = Util.on_very_lazy

-- 将 LazyVim 设置为全局变量，保持兼容性
_G.LazyVim = LazyVim

return LazyVim
