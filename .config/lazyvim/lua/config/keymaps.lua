-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end


-- Keep cursor centered when moving 1/2 pages
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when moving through search results and open folds
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Remap toggle terminal
local Snacks = require("snacks")

vim.keymap.del("n", "<c-/>")
vim.keymap.del("n", "<c-_>")
map("n", "<F12>", Snacks.terminal.open, { desc = "Terminal (Root Dir)" })

vim.keymap.del("t", "<C-/>")
vim.keymap.del("t", "<c-_>")
map("t", "<F12>", "<cmd>close<cr>", { desc = "Hide Terminal" })
