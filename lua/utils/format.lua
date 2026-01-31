-- 格式化工具模块
-- 提供代码格式化功能，包括自动格式化和手动格式化

---@class util.format
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.format(...)
  end,
})

---@class Formatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number)
---@field sources fun(bufnr:number):string[]
---@field priority number

M.formatters = {} ---@type Formatter[]

--- 注册格式化器
---@param formatter Formatter
function M.register(formatter)
  M.formatters[#M.formatters + 1] = formatter
  table.sort(M.formatters, function(a, b)
    return a.priority > b.priority
  end)
end

--- 格式化表达式，用于 vim.opt.formatexpr
function M.formatexpr()
  local Util = require("utils")
  if Util.has("conform.nvim") then
    return require("conform").formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

--- 解析当前缓冲区可用的格式化器
---@param buf? number
---@return (Formatter|{active:boolean,resolved:string[]})[]
function M.resolve(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local have_primary = false
  ---@param formatter Formatter
  return vim.tbl_map(function(formatter)
    local sources = formatter.sources(buf)
    local active = #sources > 0 and (not formatter.primary or not have_primary)
    have_primary = have_primary or (active and formatter.primary) or false
    return setmetatable({
      active = active,
      resolved = sources,
    }, { __index = formatter })
  end, M.formatters)
end

--- 显示格式化器信息
---@param buf? number
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local Util = require("utils")
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local enabled = M.enabled(buf)
  local lines = {
    "# Status",
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("- [%s] buffer **%s**"):format(
      enabled and "x" or " ",
      baf == nil and "inherit" or baf and "enabled" or "disabled"
    ),
  }
  local have = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if #formatter.resolved > 0 then
      have = true
      lines[#lines + 1] = "\n# " .. formatter.name .. (formatter.active and " ***(active)***" or "")
      for _, line in ipairs(formatter.resolved) do
        lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
      end
    end
  end
  if not have then
    lines[#lines + 1] = "\n***No formatters available for this buffer.***"
  end
  Util[enabled and "info" or "warn"](
    table.concat(lines, "\n"),
    { title = "Format (" .. (enabled and "enabled" or "disabled") .. ")" }
  )
end

--- 检查格式化是否启用
---@param buf? number
function M.enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat

  -- 如果 buffer 有局部值，使用它
  if baf ~= nil then
    return baf
  end

  -- 否则使用全局值，默认 true
  return gaf == nil or gaf
end

--- 切换格式化开关
---@param buf? boolean
function M.toggle(buf)
  M.enable(not M.enabled(), buf)
end

--- 启用/禁用格式化
---@param enable? boolean
---@param buf? boolean
function M.enable(enable, buf)
  if enable == nil then
    enable = true
  end
  if buf then
    vim.b.autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
  M.info()
end

--- 执行格式化
---@param opts? {force?:boolean, buf?:number}
function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not ((opts and opts.force) or M.enabled(buf)) then
    return
  end

  local Util = require("utils")
  local done = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if formatter.active then
      done = true
      Util.try(function()
        return formatter.format(buf)
      end, { msg = "Formatter `" .. formatter.name .. "` failed" })
    end
  end

  if not done and opts and opts.force then
    Util.warn("No formatter available", { title = "Format" })
  end
end

--- 健康检查
function M.health()
  local Config = require("lazy.core.config")
  local has_plugin = Config.spec.plugins["none-ls.nvim"]
  local has_extra = vim.tbl_contains(Config.spec.modules, "lazyvim.plugins.extras.lsp.none-ls")
  if has_plugin and not has_extra then
    local Util = require("utils")
    Util.warn({
      "`conform.nvim` and `nvim-lint` are now the default formatters and linters.",
      "",
      "You can use those plugins together with `none-ls.nvim`,",
      "but you need to configure them properly for formatting to work correctly.",
    })
  end
end

--- 设置格式化功能
function M.setup()
  M.health()

  -- 自动格式化 autocmd
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("AutoFormat", {}),
    callback = function(event)
      M.format({ buf = event.buf })
    end,
  })

  -- 手动格式化命令
  vim.api.nvim_create_user_command("Format", function()
    M.format({ force = true })
  end, { desc = "Format selection or buffer" })

  -- 格式化信息命令
  vim.api.nvim_create_user_command("FormatInfo", function()
    M.info()
  end, { desc = "Show info about the formatters for the current buffer" })
end

--- Snacks toggle 集成（如果使用 snacks.nvim）
---@param buf? boolean
function M.snacks_toggle(buf)
  return Snacks.toggle({
    name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
    get = function()
      if not buf then
        return vim.g.autoformat == nil or vim.g.autoformat
      end
      return M.enabled()
    end,
    set = function(state)
      M.enable(state, buf)
    end,
  })
end

return M
