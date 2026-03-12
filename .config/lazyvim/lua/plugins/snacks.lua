return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>gy",
      desc = "Lazygit yadm",
      function()
        Snacks.lazygit({
          args = {
            "--use-config-file",
            vim.env.HOME .. "/.config/yadm/lazygit.yml," .. vim.env.HOME .. "/.config/lazygit/config.yml",
            "--work-tree",
            vim.env.HOME,
            "--git-dir",
            vim.env.HOME .. "/.local/share/yadm/repo.git",
          },
        })
      end,
    },
  },
  opts = {
    scratch = {
      win = {
        width = 120,
        height = 0.75,
        wo = { wrap = true, linebreak = true },
      },
    },
  },
}
