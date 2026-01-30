-- 根目录检测模块
-- 来源: LazyVim util/root.lua
-- 提供项目根目录检测功能，支持 LSP、git、文件模式等多种检测方式

---@class util.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

---@class Root
---@field paths string[]
---@field spec RootSpec

---@alias RootFn fun(buf: number): (string|string[])
---@alias RootSpec string|string[]|RootFn

--- 默认的根目录检测规则
---@type RootSpec[]
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

M.detectors = {}

--- 检测器: 当前工作目录
function M.detectors.cwd()
  return { vim.uv.cwd() }
end

--- 检测器: LSP 工作区文件夹
function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end
  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients({ bufnr = buf })
  -- 过滤掉忽略的 LSP 客户端
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients) --[[@as vim.lsp.Client[] ]]
  
  for _, client in pairs(clients) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end
  
  local Util = require("utils")
  return vim.tbl_filter(function(path)
    path = Util.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

--- 检测器: 文件模式匹配
---@param buf number
---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()
  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then
        return true
      end
      -- 支持通配符模式
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]
  return pattern and { vim.fs.dirname(pattern) } or {}
end

--- 获取 buffer 的真实路径
function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

--- 获取当前工作目录
function M.cwd()
  return M.realpath(vim.uv.cwd()) or ""
end

--- 获取文件的真实路径
function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.fn.has("win32") == 0 and vim.uv.fs_realpath(path) or path
  local Util = require("utils")
  return Util.norm(path)
end

--- 解析检测规则为检测函数
---@param spec RootSpec
---@return RootFn
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

--- 检测所有可能的根目录
---@param opts? { buf?: number, spec?: RootSpec[], all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type Root[]
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    -- 按长度排序，优先使用更深的路径
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end
  return ret
end

--- 显示根目录信息
function M.info()
  local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec

  local roots = M.detect({ all = true })
  local lines = {} ---@type string[]
  local first = true
  for _, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(root.spec) == "table" and table.concat(root.spec, ", ") or root.spec
      )
      first = false
    end
  end
  lines[#lines + 1] = "```lua"
  lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
  lines[#lines + 1] = "```"
  local Util = require("utils")
  Util.info(lines, { title = "Root Directories" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

--- 根目录缓存
---@type table<number, string>
M.cache = {}

--- 设置根目录检测功能
function M.setup()
  vim.api.nvim_create_user_command("Root", function()
    require("utils.root").info()
  end, { desc = "Show root directories for the current buffer" })

  -- 清除缓存的时机
  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
end

--- 获取根目录
--- 基于以下优先级:
--- * LSP workspace folders
--- * LSP root_dir
--- * 文件名的根模式
--- * cwd 的根模式
---@param opts? {normalize?:boolean, buf?:number}
---@return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]
  if not ret then
    local roots = M.detect({ all = false, buf = buf })
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end
  if opts and opts.normalize then
    return ret
  end
  local Util = require("utils")
  return Util.is_win() and ret:gsub("/", "\\") or ret
end

--- 获取 git 根目录
function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

--- 漂亮的路径显示（预留接口）
---@param opts? {hl_last?: string}
function M.pretty_path(opts)
  return ""
end

return M
