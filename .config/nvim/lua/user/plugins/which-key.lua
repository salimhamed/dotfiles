local M = {
  "folke/which-key.nvim",
  dependencies = {
    { "echasnovski/mini.icons", version = false },
    { "nvim-tree/nvim-web-devicons" },
  },
}

function M.config(_, _)
  require("which-key").setup()
  require("which-key").add({
    { "<Leader>a", group = "avante" },
    { "<Leader>b", group = "buffers" },
    { "<Leader>c", group = "code" },
    { "<Leader>d", group = "debug" },
    { "<Leader>f", group = "find" },
    { "<Leader>g", group = "git" },
    { "<Leader>h", group = "harpoon" },
    { "<Leader>q", group = "sessions" },
    { "<Leader>x", group = "trouble" },
    { "<Leader>fy", group = "yadm" },
  })
end

return M
