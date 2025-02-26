return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.injected = { options = { ignore_errors = false } }
    opts.formatters.shfmt = {
      args = { "-i", "4", "-ci" },
    }
    return opts
  end,
}
