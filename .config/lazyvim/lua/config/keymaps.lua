-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = LazyVim.safe_keymap_set

-- Yank relative path to clipboard (e.g., src/file.lua)
map("n", "<leader>yp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Yank Relative File Path" })

-- Yank absolute path to clipboard (e.g., /Users/.../src/file.lua)
map("n", "<leader>yP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Yank Absolute File Path" })

-- Yank file reference with current line number (e.g., src/file.lua:42)
map("n", "<leader>yr", function()
  local ref = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Yank Reference" })

-- Yank file reference with line range from visual selection (e.g., src/file.lua:10-15)
map("v", "<leader>yr", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  local l1 = math.min(start_line, end_line)
  local l2 = math.max(start_line, end_line)
  local path = vim.fn.expand("%:.")
  local ref = l1 == l2 and (path .. ":" .. l1) or (path .. ":" .. l1 .. "-" .. l2)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Yank Reference" })

-- Yank absolute file reference with current line number (e.g., /Users/.../file.lua:42)
map("n", "<leader>yR", function()
  local ref = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Yank Absolute Reference" })

-- Yank absolute file reference with line range from visual selection (e.g., /Users/.../file.lua:10-15)
map("v", "<leader>yR", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  local l1 = math.min(start_line, end_line)
  local l2 = math.max(start_line, end_line)
  local path = vim.fn.expand("%:p")
  local ref = l1 == l2 and (path .. ":" .. l1) or (path .. ":" .. l1 .. "-" .. l2)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Yank Absolute Reference" })

-- Keep cursor centered when moving 1/2 pages
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when moving through search results and open folds
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Split and send current buffer to new window, show alternate in original
-- If no alternate buffer exists, just perform a normal split
map("n", "<leader>wV", function()
  local alt_buf = vim.fn.bufnr("#")
  vim.cmd("vsplit")
  if alt_buf ~= -1 and vim.api.nvim_buf_is_valid(alt_buf) then
    vim.cmd("wincmd p")
    vim.cmd("buffer " .. alt_buf)
    vim.cmd("wincmd p")
  end
end, { desc = "Split window vertically & send" })

-- Same as above but with a horizontal split
map("n", "<leader>wS", function()
  local alt_buf = vim.fn.bufnr("#")
  vim.cmd("split")
  if alt_buf ~= -1 and vim.api.nvim_buf_is_valid(alt_buf) then
    vim.cmd("wincmd p")
    vim.cmd("buffer " .. alt_buf)
    vim.cmd("wincmd p")
  end
end, { desc = "Split window & send" })
