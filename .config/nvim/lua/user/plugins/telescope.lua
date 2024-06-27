local M = {
  "nvim-telescope/telescope.nvim",
  -- tag = "0.1.1",
  -- TODO: install from master to avoid deprecation message
  -- 0.1.2 should be available soon.
  -- https://github.com/nvim-telescope/telescope.nvim/issues/2472#issuecomment-1515253884
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "smartpde/telescope-recent-files",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
  },
  opts = function()
    local trouble = require("trouble.sources.telescope")
    local actions = require("telescope.actions")
    return {
      defaults = {
        mappings = {
          i = {
            ["<C-w>"] = "which_key", -- (default: <C-/>, which is used to open terminal)
            -- similar keymaps to the rest of the neovim setup
            ["<C-x>"] = trouble.open,
            ["<C-_>"] = actions.select_horizontal,
          },
          n = {
            -- similar keymaps to the rest of the neovim setup
            ["<C-x>"] = trouble.open,
            ["<C-_>"] = actions.select_horizontal,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
        file_browser = {
          hidden = true,
          auto_depth = true,
          grouped = true,
          respect_gitignore = true,
          use_fd = true,
          git_status = true,
          select_buffer = true,
          display_stat = false,
        },
      },
    }
  end,
}

function M.config(_, opts)
  require("telescope").setup(opts)

  -- load extensions
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("recent_files")

  local builtin = require("telescope.builtin")
  local map = require("user.utils.map").map
  local get_yadm_files = require("user.utils.yadm").get_yadm_files
  local find_recent_files = require("telescope").extensions.recent_files.pick
  local file_browser = require("telescope").extensions.file_browser.file_browser

  -- function for grep over yadm files
  local function yadm_live_grep()
    builtin.live_grep({
      cmd = vim.env.HOME,
      search_dirs = get_yadm_files(),
    })
  end

  -- function for finding yadm files
  local function yadm_find_files()
    builtin.find_files({
      cmd = vim.env.HOME,
      search_dirs = get_yadm_files(),
    })
  end

  -- telescope keymaps
  map("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Fu(z)zy search buffer" })
  map("n", "<leader>fi", builtin.builtin, { desc = "Find built(i)n telescope pickers" })
  map("n", "<leader>ff", builtin.find_files, { desc = "Find (f)iles" })
  map("n", "<leader>fg", builtin.git_files, { desc = "Find (g)it files" })
  map("n", "<leader>fp", builtin.live_grep, { desc = "Search with gre(p)" })
  map("n", "<leader>fb", builtin.buffers, { desc = "Find (b)uffer" })
  map("n", "<leader>fh", builtin.help_tags, { desc = "Find (h)elp tags" })
  map("n", "<leader>fc", builtin.commands, { desc = "Find (c)ommands" })
  map("n", "<leader>fk", builtin.keymaps, { desc = "Find (k)eymaps" })
  map("n", "<leader>fe", file_browser, { desc = "File (e)xplorer" })
  map("n", "<leader>fr", find_recent_files, { desc = "Find (r)ecent files" })
  map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find buffer (s)ymbols" })
  map("n", "<leader>fx", builtin.diagnostics, { desc = "List diagnostics" })

  -- yadm keymaps
  map("n", "<leader>fyf", yadm_find_files, { desc = "Find yadm (f)iles" })
  map("n", "<leader>fyp", yadm_live_grep, { desc = "Search yadm files with gre(p)" })
end

return M
