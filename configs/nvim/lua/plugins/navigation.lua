return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>e",
        "<cmd>Neotree toggle filesystem reveal left<cr>",
        desc = "Explorer",
      },
      {
        "<C-n>",
        "<cmd>Neotree filesystem reveal left<cr>",
        desc = "Reveal file in explorer",
      },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "",
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 34,
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      {
        "<C-p>",
        function()
          require("telescope.builtin").find_files({
            hidden = true,
            no_ignore = false,
          })
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fa",
        function()
          require("telescope.builtin").find_files({
            hidden = true,
            no_ignore = true,
          })
        end,
        desc = "Find all files",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help",
      },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "target/",
            "%.gradle/",
          },
        },
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({}),
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
