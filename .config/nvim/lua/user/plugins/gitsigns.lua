local M = {
  "lewis6991/gitsigns.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "seanbreckenridge/gitsigns-yadm.nvim",
  },
  opts = {
    -- setup for gitsigns-yadm.nvim
    _on_attach_pre = function(_, callback)
      require("gitsigns-yadm").yadm_signs(callback)
    end,
    -- end setup for gitsigns-yadm.nvim
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function diff_this()
        gs.diffthis(nil, { split = "rightbelow" })
      end

      local function diff_this_against()
        local base = vim.fn.input("Diff against: ")
        gs.diffthis(base, { split = "rightbelow" })
      end

      local function blame_line()
        gs.blame_line({ full = true })
      end

      local map = require("user.utils.map").map
      map("n", "]h", gs.next_hunk, { buffer = buffer, desc = "next git hunk" })
      map("n", "[h", gs.prev_hunk, { buffer = buffer, desc = "prev git hunk" })

      -- staging
      map({ "n", "v" }, "<leader>ga", ":Gitsigns stage_hunk<CR>", { buffer = buffer, desc = "(a)dd/stage hunk" })
      map("n", "<leader>gA", gs.stage_buffer, { buffer = buffer, desc = "(A)dd/stage buffer" })

      -- resetting
      map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { buffer = buffer, desc = "(r)eset hunk" })
      map("n", "<leader>gR", gs.reset_buffer, { buffer = buffer, desc = "(R)eset buffer" })

      -- diff
      map("n", "<leader>gp", gs.preview_hunk, { buffer = buffer, desc = "(p)review Hunk" })
      map("n", "<leader>gd", diff_this, { buffer = buffer, desc = "(d)iff current buffer" })
      map("n", "<leader>gD", diff_this_against, { buffer = buffer, desc = "(D)iff current buffer against..." })

      -- blame
      map("n", "<leader>gb", gs.toggle_current_line_blame, { buffer = buffer, desc = "Toggle (b)lame" })
      map("n", "<leader>gB", blame_line, { buffer = buffer, desc = "Show (B)lame popover" })
    end,
  },
}

function M.config(_, opts)
  require("gitsigns").setup(opts)
end

return M
