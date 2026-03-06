return {
  "nvim-telescope/telescope.nvim",
  keys = function(_, _keys)
    local builtin = require("telescope.builtin")

    -- find files including gitignored files (excludes .venv)
    local function find_files_no_ignore()
      builtin.find_files({
        no_ignore = true,
        file_ignore_patterns = { "^%.venv/" },
      })
    end

    -- returns all files tracked by yadm
    local function get_yadm_files()
      local output = vim.fn.systemlist("yadm --no-pager --literal-pathspecs ls-files")
      if vim.v.shell_error ~= 0 then
        print("Error running 'yadm ls-files'.")
        return {}
      end
      local files = {}
      for _, file in ipairs(output) do
        table.insert(files, file)
      end
      return files
    end

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

    -- add custom keymaps to existing keymaps
    table.insert(_keys, { "<leader>fI", find_files_no_ignore, desc = "Find Files (no ignore)" })
    table.insert(_keys, { "<leader>fyf", yadm_find_files, desc = "Find yadm Files" })
    table.insert(_keys, { "<leader>fyp", yadm_live_grep, desc = "Search yadm files with gre(p)" })
    table.insert(_keys, { "<leader>sQ", builtin.quickfixhistory, desc = "Quickfix History" })

    return _keys
  end,
}
