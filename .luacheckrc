-- Luacheck configuration for Neovim dotfiles
globals = {
  "vim",
}

max_line_length = 120

-- Suppress common Neovim config false positives
ignore = {
  "111", -- setting non-standard global variable (M = {} module pattern)
  "112", -- mutating non-standard global variable (M.func = ...)
  "113", -- accessing undefined variable (return M)
  "212", -- unused argument (common in callbacks)
  "213", -- unused loop variable (common with _ placeholder)
}
