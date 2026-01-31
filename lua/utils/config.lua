-- 提供配置管理和初始化功能

local Util = require("utils")

---@class Config
local M = {}

M.version = "15.13.0"

---@class ConfigOptions
local defaults = {
  -- colorscheme 可以是字符串或函数
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load()
  end,
  -- 加载默认设置
  defaults = {
    autocmds = true, -- config.autocmds
    keymaps = true, -- config.keymaps
  },
  -- icons（从 utils.icons 获取）
  icons = Util.icons or {},
  ---@type table<string, string[]|boolean>?
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Property",
      "Struct",
      "Trait",
    },
  },
}

---@type ConfigOptions
local options
local lazy_clipboard

---@param opts? ConfigOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- autocmds 可以延迟加载（当不打开文件时）
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("ConfigInit", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      -- 设置格式化、根目录检测
      Util.format.setup()
      Util.root.setup()

      -- 创建自定义命令
      vim.api.nvim_create_user_command("Health", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })
    end,
  })

  -- 加载配色方案
  Util.track("colorscheme")
  Util.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  Util.track()
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      Util.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  
  -- 只加载用户文件（不加载 lazyvim.config.* 因为我们已经迁移了）
  _load("config." .. name)
  
  if vim.bo.filetype == "lazy" then
    vim.cmd([[do VimResized]])
  end
end

M.did_init = false
M._options = {} ---@type vim.wo|vim.bo

function M.init()
  if M.did_init then
    return
  end
  M.did_init = true

  -- 延迟通知直到 vim.notify 被替换
  Util.lazy_notify()

  -- 加载 options
  M.load("options")

  -- 保存一些选项以跟踪默认值
  M._options.indentexpr = vim.o.indentexpr
  M._options.foldmethod = vim.o.foldmethod
  M._options.foldexpr = vim.o.foldexpr

  -- 延迟内置剪贴板处理
  lazy_clipboard = vim.opt.clipboard:get()
  vim.opt.clipboard = ""

  Util.plugin.setup()
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    return options[key]
  end,
})

return M
