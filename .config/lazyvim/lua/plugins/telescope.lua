return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require("telescope.actions")

    -- Override default <C-q> to populate the quickfix list and open it in
    -- Trouble instead of the built-in quickfix window
    local function send_to_qflist_and_open_trouble(prompt_bufnr)
      actions.send_to_qflist(prompt_bufnr)
      vim.schedule(function()
        vim.cmd("Trouble qflist open focus=true")
      end)
    end

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      mappings = {
        i = { ["<C-q>"] = send_to_qflist_and_open_trouble },
        n = { ["<C-q>"] = send_to_qflist_and_open_trouble },
      },
    })
  end,
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
