M = {
  "zbirenbaum/copilot.lua",
  enabled = require("user.utils.project_settings").is_copilot_lua_enabled,
  -- lazy load on Copilot command
  cmd = "Copilot",
  -- lazy load on entering insert
  event = "InsertEnter",
  opts = {
    -- disable auto suggestions because suggestions are integrated with cmp
    suggestion = { enabled = false },
    panel = { enabled = false },
  },
  config = function(_, opts)
    require("copilot").setup(opts)
  end,
}

return M
