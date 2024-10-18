local M = {}

-- see nvim-lspconfig for information about server configuration options
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
M.servers_options = {
  bashls = {
    filetypes = { "sh", "zsh", "bash" },
  },
  cssls = {},
  docker_compose_language_service = {},
  dockerls = {},
  emmet_ls = {
    filetypes = {
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "less",
      "sass",
      "scss",
      "typescriptreact",
      "vue",
    },
  },
  eslint = {
    settings = {
      -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      workingDirectory = { mode = "auto" },
    },
    on_attach = function(_, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end,
  },
  html = {},
  jsonls = {},
  tailwindcss = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = {
          -- avoid prompt about using third party libraries
          -- https://github.com/LuaLS/lua-language-server/discussions/1688#discussioncomment-4185003
          checkThirdParty = false,
        },
        -- Do not send telemetry data
        telemetry = {
          enable = false,
        },
        completion = {
          -- enable call snippets with neodev.nvim
          -- see https://github.com/folke/neodev.nvim
          callSnippet = "Replace",
        },
      },
    },
  },
  pyright = {},
  taplo = {},
  yamlls = {
    settings = {
      yaml = {
        keyOrdering = false,
        -- by default schemas are automatically downloaded from https://www.schemastore.org/json/
        -- this was throwing some false positives with .config/alacritty/alacritty.yaml
        -- https://github.com/distinction-dev/alacritty-schema/issues/3
        schemaStore = { enable = false },
      },
    },
  },
}

-- optinoal custom setup function
M.server_setup = {
  -- Example of custom setup
  -- tsserver = function(lsp_config_setup_opts)
  --   require("typescript").setup({
  --     disable_commands = true, -- commands are configured with null-ls
  --     debug = false,
  --     go_to_source_definition = {
  --       fallback = true,
  --     },
  --     server = lsp_config_setup_opts,
  --   })
  -- end,
}

function M.get_server_names()
  return vim.tbl_keys(M.servers_options)
end

return M
