return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.injected = { options = { ignore_errors = false } }
    opts.formatters.shfmt = {
      args = { "-i", "4", "-ci" },
    }
    opts.formatters.taplo = {
      args = {
        "format",
        "--option",
        "indent_string=    ",
        "--option",
        "array_auto_collapse=false",
        "--stdin-filepath",
        "$FILENAME",
        "-",
      },
    }
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.toml = { "taplo" }
    return opts
  end,
}
