-- Resolve the directory for the selected node (uses parent if node is a file)
local function get_node_dir(state)
  local node = state.tree:get_node()
  local path = node:get_id()
  if node.type ~= "directory" then
    path = vim.fn.fnamemodify(path, ":h")
  end
  return path
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "s1n7ax/nvim-window-picker",
  },
  opts = {
    -- Show hidden/filtered files (e.g., dotfiles) in the tree
    filesystem = {
      filtered_items = {
        visible = true,
      },
      async_directory_scan = "auto",
      scan_mode = "deep",
      git_status_async_options = { timeout = 500 },
    },
    window = {
      mappings = {
        -- Custom actions group
        ["F"] = { "show_help", nowait = false, config = { title = "Custom Actions", prefix_key = "F" } },
        -- Copy relative path to clipboard
        ["Fy"] = {
          function(state)
            local node = state.tree:get_node()
            local path = vim.fn.fnamemodify(node:get_id(), ":.")
            vim.fn.setreg("+", path)
            vim.notify("Copied: " .. path)
          end,
          desc = "Copy Relative Path",
        },
        -- Live grep scoped to the selected directory
        ["Fg"] = {
          function(state)
            local path = get_node_dir(state)
            local rel_path = vim.fn.fnamemodify(path, ":~:.")
            require("telescope.builtin").live_grep({
              search_dirs = { path },
              prompt_title = "Grep in " .. rel_path,
            })
          end,
          desc = "Grep in Directory",
        },
        -- Find files scoped to the selected directory
        ["Ff"] = {
          function(state)
            local path = get_node_dir(state)
            local rel_path = vim.fn.fnamemodify(path, ":~:.")
            require("telescope.builtin").find_files({
              search_dirs = { path },
              prompt_title = "Find Files in " .. rel_path,
            })
          end,
          desc = "Find Files in Directory",
        },
      },
    },
  },
}
