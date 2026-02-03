-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- install and configure plugins
require("lazy").setup("user.plugins", {
  install = {
    missing = true, -- install missing plugins on startup
    colorscheme = { require("user.plugins.colorscheme").colorscheme_name }, -- try to load colorscheme when starting an installation during startup
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = { enabled = false },
})
