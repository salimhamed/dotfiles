local map = require("user.utils.map").map
local dap_utils = require("user.utils.dap")

M = {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      opts = {},
      config = function(_, opts)
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup(opts)

        -- auto-open dapui when in debug mode
        dap.listeners.after.event_initialized["dapui_config"] = dap_utils.dap_ui_open
        dap.listeners.before.event_terminated["dapui_config"] = dap_utils.dap_ui_close
        dap.listeners.before.event_exited["dapui_config"] = dap_utils.dap_ui_close

        map("n", "<leader>du", dap_utils.dap_ui_toggle, { desc = "Toggle DAP (u)i" })
        map({ "n", "v" }, "<leader>de", dap_utils.dap_ui_eval, { desc = "(e)valulate expression" })
      end,
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
    {
      "mfussenegger/nvim-dap-python",
      config = function(_, _)
        local python_executable_with_debugpy = os.getenv("HOME") .. "/.local/share/virtualenvs/cli/bin/python"
        require("dap-python").setup(python_executable_with_debugpy)
        require("dap-python").test_runner = "pytest"
        local dap_python = require("dap-python")
        map("n", "<leader>dt", dap_python.test_method, { desc = "Debug (T)est" })
        map("n", "<leader>dT", dap_python.test_class, { desc = "Debug Class" })
      end,
    },
    {
      "nvim-neotest/nvim-nio",
    },
  },
  config = function()
    -- define icons for debugging
    vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#1A1B26" })
    vim.fn.sign_define("DapBreakpoint", {
      text = "",
      texthl = "DapBreakpoint",
      linehl = "",
      numhl = "DapBreakpoint",
    })

    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { ctermbg = 0, fg = "#993939", bg = "#1A1B26" })
    vim.fn.sign_define("DapBreakpointCondition", {
      text = "",
      texthl = "DapBreakpointCondition",
      linehl = "",
      numhl = "DapBreakpointCondition",
    })

    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { ctermbg = 0, fg = "#993939", bg = "#1A1B26" })
    vim.fn.sign_define("DapBreakpointRejected", {
      text = "",
      texthl = "DapBreakpointRejected",
      linehl = "DapBreakpointRejected",
      numhl = "DapBreakpointRejected",
    })

    vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379", bg = "#1A1B26" })
    vim.fn.sign_define("DapStopped", {
      text = "",
      texthl = "DapStopped",
      linehl = "",
      numhl = "DapStopped",
    })

    vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#1A1B26" })
    vim.fn.sign_define("DapLogPoint", {
      text = "",
      texthl = "DapLogPoint",
      linehl = "",
      numhl = "DapLogPoint",
    })

    -- define keymaps
    map("n", "<leader>dB", dap_utils.set_breakpoint_condition, { desc = "Set (B)reakpoint condition" })
    map("n", "<leader>db", dap_utils.toggle_breakpoint, { desc = "Toggle (b)reakpoint" })
    map("n", "<leader>dc", dap_utils.continue, { desc = "(c)ontinue" })
    map("n", "<leader>dC", dap_utils.run_to_cursor, { desc = "Run to (C)ursor" })
    map("n", "<leader>dg", dap_utils.go_to_line, { desc = "(g)o to line (no execute)" })
    map("n", "<leader>di", dap_utils.step_into, { desc = "Step (i)nto" })
    map("n", "<leader>dj", dap_utils.go_down, { desc = "Go down into current stacktrace without stepping" })
    map("n", "<leader>dk", dap_utils.go_up, { desc = "Go up in current stacktrace without stepping" })
    map("n", "<leader>dl", dap_utils.run_last, { desc = "Run (l)ast" })
    map("n", "<leader>do", dap_utils.step_out, { desc = "Step (o)ut" })
    map("n", "<leader>dO", dap_utils.step_over, { desc = "Step (O)ver" })
    map("n", "<leader>dp", dap_utils.pause, { desc = "(p)ause" })
    map("n", "<leader>dr", dap_utils.toggle_repl, { desc = "Toggle (r)epl" })
    map("n", "<leader>ds", dap_utils.session, { desc = "Go to current (s)ession" })
    map("n", "<leader>dq", dap_utils.stop_debug_session, { desc = "(q)uit debug session" })
    map("n", "<leader>dw", dap_utils.widgets, { desc = "(w)idgets" })
  end,
}

return M
