return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "super-tab",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
        },
      },
      signature = {
        enabled = true,
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = {
        implementation = "lua",
      },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
  },
}
