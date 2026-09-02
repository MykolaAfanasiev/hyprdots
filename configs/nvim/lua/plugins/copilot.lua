return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<M-l>",
          accept_word = "<M-w>",
          accept_line = "<M-j>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
    },
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = {
      "CopilotChat",
      "CopilotChatToggle",
      "CopilotChatExplain",
      "CopilotChatReview",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "zbirenbaum/copilot.lua",
    },
    keys = {
      {
        "<leader>cc",
        "<cmd>CopilotChatToggle<cr>",
        desc = "Copilot Chat",
      },
      {
        "<leader>ce",
        "<cmd>CopilotChatExplain<cr>",
        mode = { "n", "v" },
        desc = "Copilot Explain",
      },
      {
        "<leader>cr",
        "<cmd>CopilotChatReview<cr>",
        mode = { "n", "v" },
        desc = "Copilot Review",
      },
    },
    opts = {
      window = {
        layout = "vertical",
        width = 0.45,
        border = "rounded",
      },
    },
  },
}
