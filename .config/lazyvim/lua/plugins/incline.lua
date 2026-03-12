return {
  "b0o/incline.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  event = "VeryLazy",

  -- Register <leader>uN toggle after setup (Snacks not available during init)
  config = function(_, opts)
    require("incline").setup(opts)
    Snacks.toggle.new({
      id = "incline",
      name = "Filename Indicator",
      get = function()
        return require("incline").is_enabled()
      end,
      set = function(state)
        if state then
          require("incline").enable()
        else
          require("incline").disable()
        end
      end,
    }):map("<leader>uN")
  end,

  opts = {
    -- Custom render: show filetype icon, parent directory, and filename.
    -- Modified buffers display in bold italic. Colors use Catppuccin palette
    -- and dim when the window is unfocused.
    render = function(props)
      local buf_name = vim.api.nvim_buf_get_name(props.buf)
      local filename = vim.fn.fnamemodify(buf_name, ":t")
      if filename == "" then
        filename = "[No Name]"
      end

      local rel_path = vim.fn.fnamemodify(buf_name, ":~:.")
      local parent = vim.fn.fnamemodify(rel_path, ":h")

      local icon, hl = MiniIcons.get("file", filename)
      local icon_color = vim.api.nvim_get_hl(0, { name = hl }).fg
      local modified = vim.bo[props.buf].modified

      -- Catppuccin surface1/surface0 for focused/unfocused backgrounds
      local bg = props.focused and "#45475a" or "#313244"
      local fg = props.focused and "#cdd6f4" or "#6c7086"
      local path_fg = props.focused and "#9399b2" or "#6c7086"

      local result = {
        guibg = bg,
        { icon, guifg = icon_color },
        { " " },
      }

      -- Truncate parent path from the left to fit the available window width,
      -- keeping the filename always fully visible.
      if parent ~= "." then
        local inc_win_width = vim.api.nvim_win_get_width(props.win)
        local inc_max_width = math.floor(inc_win_width * 0.7)
        -- 4 = icon(1) + space(1) + padding(2), 1 = trailing slash
        local inc_budget = inc_max_width - #filename - 4 - 1
        if inc_budget > 0 and #parent > inc_budget then
          parent = "…" .. parent:sub(-(inc_budget - 1))
          local inc_slash_pos = parent:find("/", 2)
          if inc_slash_pos then
            parent = "…" .. parent:sub(inc_slash_pos)
          end
        end
        table.insert(result, { parent .. "/", guifg = path_fg })
      end

      table.insert(result, { filename, guifg = fg, gui = modified and "bold,italic" or "bold" })

      return result
    end,

    -- Background colors matching the render function
    highlight = {
      groups = {
        InclineNormal = { guibg = "#45475a" },
        InclineNormalNC = { guibg = "#313244" },
      },
    },

    window = {
placement = { horizontal = "right", vertical = "top" },
      padding = { left = 1, right = 1 },
      margin = { horizontal = 0, vertical = 1 },
    },

    hide = {
      only_win = false, -- show even with a single window
    },
  },
}
