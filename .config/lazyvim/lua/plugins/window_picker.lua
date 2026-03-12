return {
  "s1n7ax/nvim-window-picker",
  version = "2.*",
  opts = {
    hint = "floating-big-letter",
    selection_chars = "ABCDEFGHIJKL",
    filter_rules = {
      autoselect_one = false,
      include_current_win = false,
      bo = {
        filetype = { "neo-tree", "neo-tree-popup", "notify", "NvimTree" },
        buftype = { "terminal", "quickfix" },
      },
    },
  },
  -- Pick a target window, then swap the current buffer into it
  keys = {
    {
      "<leader>bm",
      function()
        local wp_target_win = require("window-picker").pick_window()
        if not wp_target_win then
          return
        end
        local wp_current_buf = vim.api.nvim_get_current_buf()
        local wp_target_buf = vim.api.nvim_win_get_buf(wp_target_win)
        vim.api.nvim_win_set_buf(wp_target_win, wp_current_buf)
        vim.api.nvim_win_set_buf(0, wp_target_buf)
      end,
    },
  },
}
