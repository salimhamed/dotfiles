-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Treat .env files as dotenv so no LSP attaches (no shellcheck warnings),
-- but use bash treesitter parser for highlighting and commenting
vim.filetype.add({ pattern = { ["%.env"] = "dotenv", ["%.env%..*"] = "dotenv" } })
vim.treesitter.language.register("bash", "dotenv")

-- Reduce visual noise for AI tool temporary files (Claude Code, Codex, etc.)
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("ai_tool_temp_files", { clear = true }),
  callback = function(args)
    local buf_name = vim.api.nvim_buf_get_name(args.buf)
    local is_claude = buf_name:match("/claude%-prompt%-.+%.md$")
    local is_codex = buf_name:match("/private/var/folders/.+/T/%.tmp.+%.md$")
    if is_claude or is_codex then
      vim.diagnostic.enable(false, { bufnr = args.buf })
      local ok, incline = pcall(require, "incline")
      if ok and incline.is_enabled() then
        incline.disable()
      end
    end
  end,
})
