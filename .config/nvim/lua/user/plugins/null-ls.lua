local M = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "lukas-reineke/lsp-format.nvim" },
  },
}

local function codespell_ignore_file_extra_args()
  local dirs = require("plenary.scandir").ls(".", { hidden = true })
  local ignore_file = require("user.utils.match").get_match(dirs, "%.codespell%-ignorelines$")
  if ignore_file then
    return { string.format("--exclude-file=%s", ".codespell-ignorelines") }
  else
    return {}
  end
end

function M.config(_, _)
  local null_ls = require("null-ls")

  -- setup format on save plugin
  require("lsp-format").setup()
  local format_on_attach = require("lsp-format").on_attach

  null_ls.setup({
    debug = false,
    sources = {
      -- lua
      null_ls.builtins.formatting.stylua,

      -- javascript / typescript
      null_ls.builtins.formatting.prettierd,

      -- python
      null_ls.builtins.diagnostics.mypy,
      null_ls.builtins.diagnostics.pylint,
      null_ls.builtins.formatting.isort,
      null_ls.builtins.formatting.black,

      -- gitsigns
      null_ls.builtins.code_actions.gitsigns,

      -- shell
      null_ls.builtins.formatting.shfmt.with({
        extra_args = { "--indent", "4", "--case-indent" },
        filetypes = { "sh", "zsh" },
      }),

      -- markdown
      null_ls.builtins.diagnostics.markdownlint,

      -- spelling
      null_ls.builtins.diagnostics.codespell.with({
        extra_args = codespell_ignore_file_extra_args(),
      }),
      null_ls.builtins.formatting.codespell.with({
        extra_args = codespell_ignore_file_extra_args(),
      }),
    },
    on_attach = function(client, _)
      format_on_attach(client)
    end,
  })
end

return M
