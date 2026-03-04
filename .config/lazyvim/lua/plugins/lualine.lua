return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local disabled_fts = {
      "dashboard",
      "alpha",
      "ministarter",
      "snacks_dashboard",
      "neo-tree",
      "aerial",
      "Trouble",
      "lazy",
      "mason",
      "notify",
      "toggleterm",
      "lazyterm",
    }

    opts.options = opts.options or {}
    opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
    opts.options.disabled_filetypes.winbar = disabled_fts

    opts.winbar = {
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        { LazyVim.lualine.pretty_path() },
        {
          "aerial",
          sep = " › ",
          depth = 5,
          dense = false,
          dense_sep = ".",
          colored = true,
        },
      },
    }

    opts.inactive_winbar = {
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        { "filename", path = 1, color = { fg = "#6c7086" } },
      },
    }

    -- Remove aerial from statusline since it now lives in the winbar
    if opts.sections and opts.sections.lualine_c then
      for i = #opts.sections.lualine_c, 1, -1 do
        local comp = opts.sections.lualine_c[i]
        if type(comp) == "table" and comp[1] == "aerial" then
          table.remove(opts.sections.lualine_c, i)
        end
      end
    end
  end,
}
