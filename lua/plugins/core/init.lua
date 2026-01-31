-- 核心插件配置
-- 基础必需的插件

return {
  -- lazy.nvim 插件管理器本身
  {
    "folke/lazy.nvim",
    version = "*",
  },

  -- snacks.nvim - 提供各种实用功能
  -- 包括: statuscolumn, terminal, notifier, dashboard 等
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function()
      ---@type snacks.Config
      return {
        bigfile = { enabled = true },
        dashboard = { enabled = false }, -- 使用自定义 dashboard
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
          notification = {
            wo = { wrap = true }, -- 通知文本换行
          },
        },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- 设置一些常用的全局快捷键
          local Snacks = require("snacks")
         
          -- 切换功能的快捷键
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
    config = function(_, opts)
      local notify = vim.notify
      require("snacks").setup(opts)
      -- HACK: 恢复 vim.notify，让 noice.nvim 接管
      -- 这样可以让早期通知显示在 noice 历史中
      local Util = require("utils")
      if Util.has("noice.nvim") then
        vim.notify = notify
      end
    end,
  },
}
