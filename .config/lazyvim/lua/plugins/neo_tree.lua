return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    {
      "s1n7ax/nvim-window-picker",
      version = "2.*",
      config = function()
        require("window-picker").setup({
          hint = "floating-big-letter",
          selection_chars = "ABCDEFGHIJKL",
          filter_rules = {
            -- filter using buffer options
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify", "NvimTree" },
              buftype = { "terminal", "quickfix" },
            },
          },
        })
      end,
    },
  },
  opts = {
    window = {
      mappings = {
        ["<cr>"] = "open",
      },
    },
  },
}
