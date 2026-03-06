return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    {
      "s1n7ax/nvim-window-picker",
      version = "2.*",
      config = function()
        require("window-picker").setup({
          hint = "floating-big-letter",
          selection_chars = "ABCDEFGHIJKL",
          filter_rules = {
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify", "NvimTree" },
              buftype = { "terminal", "quickfix" },
            },
          },
        })
      end,
    },
  },
  opts = {
    -- Show hidden/filtered files (e.g., dotfiles) in the tree
    filesystem = {
      filtered_items = {
        visible = true,
      },
    },
    window = {
      mappings = {
        -- Copy relative path to clipboard (e.g., src/file.lua)
        ["gy"] = {
          function(state)
            local node = state.tree:get_node()
            local path = vim.fn.fnamemodify(node:get_id(), ":.")
            vim.fn.setreg("+", path)
            vim.notify("Copied: " .. path)
          end,
          desc = "Copy Relative Path",
        },
        -- Live grep scoped to the selected directory
        ["gs"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            -- Use the node's path if it's a directory, otherwise use its parent
            if node.type ~= "directory" then
              path = vim.fn.fnamemodify(path, ":h")
            end
            local rel_path = vim.fn.fnamemodify(path, ":~:.")
            require("telescope.builtin").live_grep({
              search_dirs = { path },
              prompt_title = "Grep in " .. rel_path,
            })
          end,
          desc = "Grep in Directory",
        },
      },
    },
  },
}
