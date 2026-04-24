return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  keys = {
    { "<leader>fo", "<cmd>Oil<cr>", desc = "Oil (Directory of Current File)" },
    { "<leader>fO", "<cmd>Oil .<cr>", desc = "Oil (cwd)" },
  },
}
