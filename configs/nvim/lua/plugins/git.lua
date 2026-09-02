return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      current_line_blame_opts = {
        delay = 400,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, {
            buffer = bufnr,
            desc = desc,
          })
        end

        map("]h", gs.next_hunk, "Next git hunk")
        map("[h", gs.prev_hunk, "Previous git hunk")
        map("<leader>gp", gs.preview_hunk, "Preview git hunk")
        map("<leader>gb", gs.toggle_current_line_blame, "Toggle git blame")
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" },
    keys = {
      {
        "<leader>gg",
        "<cmd>Git<cr>",
        desc = "Git status",
      },
    },
  },
}
