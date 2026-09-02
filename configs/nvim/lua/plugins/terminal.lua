return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",

    keys = {
      {
        "<leader>tt",
        "<cmd>ToggleTerm direction=float<cr>",
        desc = "Floating terminal",
      },
      {
        "<leader>th",
        "<cmd>ToggleTerm direction=horizontal<cr>",
        desc = "Horizontal terminal",
      },
      {
        "<leader>tv",
        "<cmd>ToggleTerm direction=vertical size=70<cr>",
        desc = "Vertical terminal",
      },
    },

    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      shade_terminals = false,

      float_opts = {
        border = "rounded",
      },
    },
  },
}
