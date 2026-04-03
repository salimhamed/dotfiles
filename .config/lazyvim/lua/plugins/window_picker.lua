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
      desc = "Move Buffer to Window",
      function()
        local wp_target_win = require("window-picker").pick_window()
        if not wp_target_win then
          return
        end
        local wp_current_buf = vim.api.nvim_get_current_buf()
        local wp_source_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(wp_target_win, wp_current_buf)
        local wp_alt_buf = vim.fn.bufnr("#")
        if wp_alt_buf ~= -1 and vim.api.nvim_buf_is_valid(wp_alt_buf) and wp_alt_buf ~= wp_current_buf then
          vim.api.nvim_win_set_buf(wp_source_win, wp_alt_buf)
        else
          vim.cmd("bprevious")
        end
        vim.api.nvim_set_current_win(wp_target_win)
      end,
    },
  },
}
