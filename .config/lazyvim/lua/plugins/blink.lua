return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "moyiz/blink-emoji.nvim",
    },
    opts = {
      sources = {
        default = { "emoji" },
        providers = {
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15, -- rank emoji suggestions above other sources
            opts = { insert = true }, -- insert the emoji character, not the :code:
            -- Enable emoji completion only for git commits and markdown.
            -- By default, enabled for all file-types.
            should_show_items = function()
              return vim.tbl_contains({ "gitcommit", "markdown" }, vim.o.filetype)
            end,
          },
        },
      },
    },
  },
}
