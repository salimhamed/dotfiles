-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end


-- Copy file paths to clipboard
map("n", "<leader>by", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy Relative Path" })

map("n", "<leader>bY", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy Absolute Path" })

map("n", "<leader>bR", function()
  local ref = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Copy Reference" })

map("v", "<leader>bR", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  local l1 = math.min(start_line, end_line)
  local l2 = math.max(start_line, end_line)
  local path = vim.fn.expand("%:.")
  local ref = l1 == l2 and (path .. ":" .. l1) or (path .. ":" .. l1 .. "-" .. l2)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Copy Reference" })

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
