local is_copilot_cmp_enabled = require("user.utils.project_settings").is_copilot_lua_enabled

local M = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/cmp-emoji" },
    { "hrsh7th/cmp-nvim-lsp-signature-help" },
    { "saadparwaiz1/cmp_luasnip" },
    {
      "L3MON4D3/LuaSnip",
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          -- load "vs code-like" snippets from friendly-snippets
          -- https://github.com/L3MON4D3/LuaSnip#add-snippets
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    {
      "roobert/tailwindcss-colorizer-cmp.nvim",
      config = function()
        require("tailwindcss-colorizer-cmp").setup({
          color_square_width = 2,
        })
      end,
    },
    { "onsails/lspkind.nvim" },
    {
      "zbirenbaum/copilot-cmp",
      enabled = is_copilot_cmp_enabled,
      dependencies = {
        enabled = is_copilot_cmp_enabled,
        "zbirenbaum/copilot.lua",
      },
      config = true,
    },
  },
  opts = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local confirm_selection = function(...)
      local entry = cmp.get_selected_entry()
      local default_confirm = cmp.mapping.confirm({
        select = false, -- select = true, accept currently selected item.
      })
      local copilot_confirm = cmp.mapping.confirm({
        select = false, -- select = true, accept currently selected item.
        behavior = cmp.ConfirmBehavior.Replace,
      })
      if entry and entry.source.name == "copilot" then
        return copilot_confirm(...)
      end
      return default_confirm(...)
    end

    local get_sources = function()
      if is_copilot_cmp_enabled then
        return {
          { name = "copilot", group_index = 1 },
          { name = "path", group_index = 2 },
          { name = "nvim_lsp", group_index = 2 },
          { name = "nvim_lsp_signature_help", group_index = 2 },
          { name = "emoji", group_index = 2 },
          { name = "luasnip", group_index = 3 },
          { name = "buffer", group_index = 3 },
        }
      end
      return {
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "emoji" },
        { name = "luasnip" },
        { name = "buffer" },
      }
    end

    return {
      -- configuring a snippet engine is required
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      view = {
        entries = "custom",
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        -- super tab setup
        -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#super-tab-like-mapping
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- they way you will only jump inside the snippet region
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = confirm_selection,
      }),
      sources = cmp.config.sources(get_sources()),
      -- configure lsp kind
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text", -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
          menu = {
            path = "[Path]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            buffer = "[Buffer]",
            emoji = "[Emoji]",
            copilot = "[Copilot]",
          },
          maxwidth = 50, -- prevent the popup from showing more than provided characters
          ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization.
          -- (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function(entry, vim_item)
            -- add tailwindcss color formatter
            return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
          end,
          -- setup symbol for copilot
          symbol_map = { Copilot = "" },
        }),
      },
    }
  end,
}

function M.config(_, opts)
  local cmp = require("cmp")
  cmp.setup(opts)

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })
end

return M
