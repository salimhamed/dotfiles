-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- allow sourcing of .exrc, .nvimrc and .nvim.lua
vim.opt.exrc = true
vim.opt.secure = true

-- use telescope for picker
vim.g.lazyvim_picker = "telescope"

-- python options
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Enable clipboard over SSH via OSC 52
vim.opt.clipboard = "unnamedplus"

-- register .j2 files as jinja filetype
vim.filetype.add({
  extension = {
    j2 = "jinja",
    jinja = "jinja",
    jinja2 = "jinja",
  },
})

