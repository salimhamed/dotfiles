return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>fy", group = "yadm", icon = { icon = "󰊢 ", color = "orange" } },
      { "<leader>y", group = "yank", icon = { icon = "󰆏 ", color = "yellow" }, mode = { "n", "v" } },
      { "<leader>fI", desc = "Find Files (no ignore)" },
      { "<leader>fyf", desc = "Find yadm Files" },
      { "<leader>fyg", desc = "Grep yadm Files" },
      { "<leader>sQ", desc = "Quickfix History" },
      { "<leader>gq", desc = "DiffviewClose" },
      { "<leader>bm", desc = "Move Buffer to Window" },
      { "<leader>ss", desc = "Search and Replace (selection)", icon = { icon = "󰛔 ", color = "blue" }, mode = "x" },
    },
  },
}
