-- Editor 核心插件
-- 提供编辑器增强功能（用户已配置的插件不包含在此）

return {
  -- grug-far - 多文件搜索替换
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace",
      },
    },
  },

  -- 注意：以下插件用户已有自定义配置，会自动合并：
  -- - flash.nvim
  -- - which-key.nvim
  -- - gitsigns.nvim
  -- - trouble.nvim
  -- - todo-comments.nvim
}
