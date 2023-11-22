local M = {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
  },
  build = function()
    require("nvim-treesitter.install").update({ with_sync = true })
  end,
}

function M.config()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash",
      "css",
      "dockerfile",
      "html",
      "java",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "ruby",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
    sync_install = true, -- install languages synchronously
    auto_install = true, -- auto install missing parsers when entering buffer
    highlight = {
      enable = true, -- false will disable the whole extension
    },
    -- Disable slow treesitter highlight for large files
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<M-]>",
        node_incremental = "<M-]>",
        scope_incremental = nil,
        node_decremental = "<M-[>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- lots of other queries available
        -- see https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
        keymaps = {
          -- function
          ["af"] = { query = "@function.outer", desc = "[TS] a (f)unction" },
          ["if"] = { query = "@function.inner", desc = "[TS] inner (f)unction" },
          -- class
          ["ac"] = { query = "@class.outer", desc = "[TS] a (c)lass" },
          ["ic"] = { query = "@class.inner", desc = "[TS] inner (c)lass" },
          -- parameter
          ["am"] = { query = "@parameter.outer", desc = "[TS] a para(m)eter" },
          ["im"] = { query = "@parameter.inner", desc = "[TS] inner para(m)eter" },
          -- right/left hand side assignment
          ["ar"] = { query = "@assignment.rhs", desc = "[TS] a (r)hs assignment" },
          ["al"] = { query = "@assignment.lhs", desc = "[TS] a (l)hs assignment" },
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in `ap`.
        include_surrounding_whitespace = false,
      },
    },
  })

  -- enable context
  require("treesitter-context").setup()

  -- enable treesitter folding
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldenable = true
  vim.opt.foldlevel = 5
end

return M
