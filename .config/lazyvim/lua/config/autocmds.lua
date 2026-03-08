-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Reduce visual noise for Claude Code temporary prompt files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("claude_prompt_files", { clear = true }),
  callback = function(args)
    local buf_name = vim.api.nvim_buf_get_name(args.buf)
    if buf_name:match("/T/claude%-prompt%-.+%.md$") then
      vim.diagnostic.enable(false, { bufnr = args.buf })
      local ok, incline = pcall(require, "incline")
      if ok and incline.is_enabled() then
        incline.disable()
      end
    end
  end,
})
