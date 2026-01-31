-- CMP 工具模块
-- 来源: LazyVim util/cmp.lua
-- 提供补全相关的辅助功能

---@class util.cmp
local M = {}

--- CMP 动作
---@type table<string, fun():boolean?>
M.actions = {
  -- 原生 snippet 向前跳转
  snippet_forward = function()
    if vim.snippet.active({ direction = 1 }) then
      vim.schedule(function()
        vim.snippet.jump(1)
      end)
      return true
    end
  end,
  -- 停止 snippet
  snippet_stop = function()
    if vim.snippet then
      vim.snippet.stop()
    end
  end,
}

--- 映射多个动作
---@param actions string[]
---@param fallback? string|fun()
function M.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if M.actions[name] then
        local ret = M.actions[name]()
        if ret then
          return true
        end
      end
    end
    return type(fallback) == "function" and fallback() or fallback
  end
end

--- 替换 snippet 中的占位符
---@param snippet string
---@param fn fun(placeholder:{n:number, text:string}):string
---@return string
function M.snippet_replace(snippet, fn)
  return snippet:gsub("%$%b{}", function(m)
    local n, name = m:match("^%${(%d+):(.+)}$")
    return n and fn({ n = tonumber(n), text = name }) or m
  end) or snippet
end

--- 预览 snippet
---@param snippet string
---@return string
function M.snippet_preview(snippet)
  local ok, parsed = pcall(function()
    return vim.lsp._snippet_grammar.parse(snippet)
  end)
  return ok and tostring(parsed)
    or M.snippet_replace(snippet, function(placeholder)
      return M.snippet_preview(placeholder.text)
    end):gsub("%$0", "")
end

--- 修复 snippet 中的嵌套占位符
function M.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return M.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n] or M.snippet_preview(placeholder.text)
    return "${" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
  end)
end

--- 自动添加括号（用于函数/方法补全）
---@param entry any
function M.auto_brackets(entry)
  local cmp = require("cmp")
  local Kind = cmp.lsp.CompletionItemKind
  local item = entry:get_completion_item()
  if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local prev_char = vim.api.nvim_buf_get_text(0, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] + 1, {})[1]
    if prev_char ~= "(" and prev_char ~= ")" then
      local keys = vim.api.nvim_replace_termcodes("()<left>", false, false, true)
      vim.api.nvim_feedkeys(keys, "i", true)
    end
  end
end

--- 为 snippet 添加缺失的文档
---@param window any
function M.add_missing_snippet_docs(window)
  local cmp = require("cmp")
  local Kind = cmp.lsp.CompletionItemKind
  local entries = window:get_entries()
  for _, entry in ipairs(entries) do
    if entry:get_kind() == Kind.Snippet then
      local item = entry:get_completion_item()
      if not item.documentation and item.insertText then
        item.documentation = {
          kind = cmp.lsp.MarkupKind.Markdown,
          value = string.format("```%s\n%s\n```", vim.bo.filetype, M.snippet_preview(item.insertText)),
        }
      end
    end
  end
end

--- 改进的确认函数
---@param opts? {select: boolean, behavior: any}
function M.confirm(opts)
  local cmp = require("cmp")
  opts = vim.tbl_extend("force", {
    select = true,
    behavior = cmp.ConfirmBehavior.Insert,
  }, opts or {})
  return function(fallback)
    if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
      local Util = require("utils")
      Util.create_undo()
      if cmp.confirm(opts) then
        return
      end
    end
    return fallback()
  end
end

--- 展开 snippet
function M.expand(snippet)
  -- 原生 session 不支持嵌套
  -- 总是使用顶层 session
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = M.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)

    local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
      or ("Failed to parse snippet.\n" .. err)

    local Util = require("utils")
    Util[ok and "warn" or "error"](
      ([[%s
```%s
%s
```]]):format(msg, vim.bo.filetype, snippet),
      { title = "vim.snippet" }
    )
  end

  -- 恢复顶层 session
  if session then
    vim.snippet._session = session
  end
end

--- 设置 CMP
---@param opts any
function M.setup(opts)
  for _, source in ipairs(opts.sources) do
    source.group_index = source.group_index or 1
  end

  local parse = require("cmp.utils.snippet").parse
  require("cmp.utils.snippet").parse = function(input)
    local ok, ret = pcall(parse, input)
    if ok then
      return ret
    end
    return M.snippet_preview(input)
  end

  local cmp = require("cmp")
  cmp.setup(opts)
  cmp.event:on("confirm_done", function(event)
    if vim.tbl_contains(opts.auto_brackets or {}, vim.bo.filetype) then
      M.auto_brackets(event.entry)
    end
  end)
  cmp.event:on("menu_opened", function(event)
    M.add_missing_snippet_docs(event.window)
  end)
end

return M
