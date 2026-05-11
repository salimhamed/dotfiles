return {
  "dlyongemallo/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>go", ":DiffviewOpen ", desc = "DiffviewOpen" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "DiffviewClose" },
  },
  opts = function()
    local actions = require("diffview.actions")
    return {
      view = {
        default = {
          winbar_info = true, -- show rev/branch label in each split
        },
        file_history = {
          winbar_info = true,
        },
      },
      keymaps = {
        view = {
          { "n", "]h", "]c", { desc = "Jump to the next hunk" } },
          { "n", "[h", "[c", { desc = "Jump to the previous hunk" } },
        },
        diff1_inline = {
          { "n", "]h", actions.next_inline_hunk, { desc = "Jump to the next hunk" } },
          { "n", "[h", actions.prev_inline_hunk, { desc = "Jump to the previous hunk" } },
        },
        file_panel = {
          { "n", "<PageDown>", actions.scroll_view(0.25), { desc = "Scroll the code view down" } },
          { "n", "<PageUp>", actions.scroll_view(-0.25), { desc = "Scroll the code view up" } },
        },
        file_history_panel = {
          { "n", "<PageDown>", actions.scroll_view(0.25), { desc = "Scroll the code view down" } },
          { "n", "<PageUp>", actions.scroll_view(-0.25), { desc = "Scroll the code view up" } },
        },
      },
    }
  end,
}
