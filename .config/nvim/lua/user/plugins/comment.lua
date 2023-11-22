local M = {
  "echasnovski/mini.comment",
  dependencies = {
    { "JoosepAlviste/nvim-ts-context-commentstring" },
  },
  config = function(_, _)
    -- see the following link for information on integrating nvim-ts-context-commentstring with mini.comment
    -- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations
    local ts_context_commentstring = require("ts_context_commentstring")
    ts_context_commentstring.setup({
      enable_autocmd = false,
    })

    require("mini.comment").setup({
      options = {
        custom_commentstring = function()
          return ts_context_commentstring.calculate_commentstring() or vim.bo.commentstring
        end,
      },
    })
  end,
}

return M
