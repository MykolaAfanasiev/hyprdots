local parsers = {
  "bash",
  "c",
  "cpp",
  "css",
  "dockerfile",
  "go",
  "hcl",
  "html",
  "java",
  "javascript",
  "json",
  "jsonc",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = parsers,
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
