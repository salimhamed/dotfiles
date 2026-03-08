return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- toggle hints on/off with <leader>uh
      inlay_hints = { enabled = true },
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                inlayHints = {
                  -- show parameter names at call sites
                  callArgumentNames = true,
                  -- show return types on functions without annotations
                  functionReturnTypes = true,
                  -- show inferred generic types
                  genericTypes = true,
                  -- show type annotations on variable assignments
                  variableTypes = false,
                  -- show argument names even when variable matches parameter name
                  callArgumentNamesMatching = false,
                },
              },
            },
          },
        },
      },
    },
  },
}
