return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
  keys = {
    { "<leader>fo", "<cmd>Oil<cr>", desc = "Oil (Directory of Current File)" },
    { "<leader>fO", "<cmd>Oil .<cr>", desc = "Oil (cwd)" },
  },
}
