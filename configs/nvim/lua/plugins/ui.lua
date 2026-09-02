return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1 },
        },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "neo-tree", "lazy", "mason" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
    },
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "███╗   ██╗ ██████╗ ██████╗ ███████╗██╗  ██╗██╗██╗     ",
        "████╗  ██║██╔═══██╗██╔══██╗██╔════╝╚██╗██╔╝██║██║     ",
        "██╔██╗ ██║██║   ██║██████╔╝█████╗   ╚███╔╝ ██║██║     ",
        "██║╚██╗██║██║   ██║██╔══██╗██╔══╝   ██╔██╗ ██║██║     ",
        "██║ ╚████║╚██████╔╝██║  ██║███████╗██╔╝ ██╗██║███████╗",
        "╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "󰈞  Find file", "<cmd>Telescope find_files<cr>"),
        dashboard.button("g", "󰱼  Live grep", "<cmd>Telescope live_grep<cr>"),
        dashboard.button("r", "󰄉  Recent files", "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
        dashboard.button("m", "󰟾  Mason", "<cmd>Mason<cr>"),
        dashboard.button("q", "󰅚  Quit", "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = "Hyprdots Norexil"
      alpha.setup(dashboard.config)
    end,
  },
}
