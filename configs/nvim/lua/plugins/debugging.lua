return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("dap-go").setup()

      local debugpy_python = vim.fn.stdpath("data")
        .. "/mason/packages/debugpy/venv/bin/python"

      if vim.fn.executable(debugpy_python) == 1 then
        require("dap-python").setup(debugpy_python)
      end

      dap.listeners.before.attach.norexil_dapui = function()
        dapui.open()
      end
      dap.listeners.before.launch.norexil_dapui = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.norexil_dapui = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.norexil_dapui = function()
        dapui.close()
      end
    end,
  },
}
