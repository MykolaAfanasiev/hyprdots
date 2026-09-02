return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        dark = "mocha",
      },
      transparent_background = false,
      term_colors = true,
      auto_integrations = true,
      integrations = {
        blink_cmp = { style = "bordered" },
        gitsigns = true,
        neotree = true,
        telescope = {
          enabled = true,
        },
        treesitter = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
