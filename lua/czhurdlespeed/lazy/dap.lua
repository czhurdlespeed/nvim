return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>DB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>Dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>Di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>Do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>DO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>Dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>Dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>Du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>Dt", function() require("dap").terminate() end, desc = "Terminate" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      local mason = vim.fn.stdpath("data") .. "/mason/packages"
      local exists = function(p) return vim.uv.fs_stat(p) ~= nil end

      -- Python: prefer mason's debugpy venv, else fall back to system python3.
      local debugpy_python = mason .. "/debugpy/venv/bin/python"
      require("dap-python").setup(exists(debugpy_python) and debugpy_python or "python3")

      -- Go (delve)
      require("dap-go").setup()

      -- C / C++ via codelldb — only register if codelldb is actually installed.
      -- (rust DAP is handled by rustaceanvim.) If codelldb's mason download failed,
      -- run :MasonInstall codelldb and this picks it up on next start, no config change.
      local codelldb = mason .. "/codelldb/extension/adapter/codelldb"
      if exists(codelldb) then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = { command = codelldb, args = { "--port", "${port}" } },
        }
        for _, ft in ipairs({ "c", "cpp" }) do
          dap.configurations[ft] = {
            {
              name = "Launch",
              type = "codelldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          }
        end
      end
    end,
  },
}
