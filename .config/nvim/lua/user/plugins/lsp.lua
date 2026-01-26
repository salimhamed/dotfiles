local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "folke/neodev.nvim" },
    { "rcarriga/nvim-dap-ui" },
  },
}

function M.config()
  -- folke/neodev.nvim must be setup before lspconfig
  -- this gives better lsp experience for lua
  -- https://github.com/folke/neodev.nvim
  require("neodev").setup({
    library = { plugins = { "nvim-dap-ui" }, types = true },
  })
  local lspconfig = require("lspconfig")
  local server_options = require("user.utils.servers").servers_options
  local server_setup = require("user.utils.servers").server_setup
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  local lsp_utils = require("user.utils.lsp")

  -- configure lsp servers
  for _, server_name in pairs(require("user.utils.servers").get_server_names()) do
    local required_options = { capabilities = cmp_nvim_lsp.default_capabilities() }
    local merged_options = vim.tbl_extend("error", required_options, server_options[server_name])
    local setup_function = server_setup[server_name]
    if setup_function == nil then
      lspconfig[server_name].setup(merged_options)
    else
      setup_function(merged_options)
    end
  end

  -- define icons for diagnostics
  vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
  vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
  vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
  vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
  vim.fn.sign_define("DiagnosticSignOk", { text = "", texthl = "DiagnosticSignOk" })

  -- configure keymaps
  local map = require("user.utils.map").map

  map("n", "K", lsp_utils.hover_information, { desc = "[LSP] Show information about symbol" })
  map("n", "gd", lsp_utils.definitions, { desc = "[LSP] Goto (d)efinition" })
  map("n", "gD", lsp_utils.declarations, { desc = "[LSP] Go to (D)eclaration" })
  map("n", "gi", lsp_utils.implementations, { desc = "[LSP] Go to (i)mplementation" })
  map("n", "go", lsp_utils.type_definitions, { desc = "[LSP] Go to type definition" })
  map("n", "gr", lsp_utils.references, { desc = "[LSP] Show (r)eferences" })
  map("n", "gs", lsp_utils.signature_help, { desc = "[LSP] Show (s)ignature help" })
  map("n", "<F2>", lsp_utils.incremental_rename, { desc = "[LSP] Rename symbol", expr = true })
  map("n", "<F3>", lsp_utils.format, { desc = "[LSP] Format current buffer" })
  map("n", "<F4>", lsp_utils.code_action, { desc = "[LSP] Code action" })
  map("n", "<F5>", lsp_utils.source_code_action, { desc = "[LSP] Code actions for source code" })

  -- diagnostics
  map("n", "gl", lsp_utils.open_diagnostic_float, { desc = "[LSP] Show (l)ine diagnostics" })
  map("n", "]d", lsp_utils.diagnostic_goto(true), { desc = "[LSP] Next (d)iagnostic" })
  map("n", "[d", lsp_utils.diagnostic_goto(false), { desc = "[LSP] Prev (d)iagnostic" })
  map("n", "]e", lsp_utils.diagnostic_goto(true, "ERROR"), { desc = "[LSP] Next (e)rror" })
  map("n", "[e", lsp_utils.diagnostic_goto(false, "ERROR"), { desc = "[LSP] Prev (e)rror" })
  map("n", "]w", lsp_utils.diagnostic_goto(true, "WARN"), { desc = "[LSP] Next (w)arning" })
  map("n", "[w", lsp_utils.diagnostic_goto(false, "WARN"), { desc = "[LSP] Prev (w)arning" })

  -- leader keymaps
  map("n", "<leader>cd", lsp_utils.toggle_diagnostics, { desc = "Toggle (d)iagnostics on/off" })
end

return M
