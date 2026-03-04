return {
  "b0o/incline.nvim",
  event = "VeryLazy",
  opts = {
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

      local bg = props.focused and "#45475a" or "#313244"
      local fg = props.focused and "#cdd6f4" or "#6c7086"
      local path_fg = props.focused and "#9399b2" or "#6c7086"

      local result = {
        guibg = bg,
        { icon, guifg = icon_color },
        { " " },
      }

      if parent ~= "." then
        table.insert(result, { parent .. "/", guifg = path_fg })
      end

      table.insert(result, { filename, guifg = fg, gui = modified and "bold,italic" or "bold" })

      return result
    end,
    highlight = {
      groups = {
        InclineNormal = { guibg = "#45475a" },
        InclineNormalNC = { guibg = "#313244" },
      },
    },
    window = {
      placement = { horizontal = "left", vertical = "top" },
      padding = { left = 1, right = 1 },
      margin = { horizontal = 0, vertical = 1 },
    },
    hide = {
      only_win = false,
    },
  },
}
