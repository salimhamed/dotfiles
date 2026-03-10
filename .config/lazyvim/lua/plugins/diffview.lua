return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  opts = {
    view = {
      default = {
        winbar_info = true, -- show rev/branch label in each split
      },
      file_history = {
        winbar_info = true,
      },
    },
  },
}
