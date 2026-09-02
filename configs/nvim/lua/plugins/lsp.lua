local servers = {
  "lua_ls",
  "bashls",
  "gopls",
  "yamlls",
  "terraformls",
  "ansiblels",
  "dockerls",
  "docker_compose_language_service",
  "cssls",
  "jsonls",
  "lemminx",
  "pyright",
  "sqlls",
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      {
        "mason-org/mason.nvim",
        opts = {
          ui = {
            border = "rounded",
          },
        },
      },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.config("terraformls", {
        settings = {
          terraform = {
            ignoreSingleFileWarning = true,
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("norexil-lsp", { clear = true }),
        callback = function(event)
          local opts = {
            buffer = event.buf,
            silent = true,
          }

          local function map(lhs, rhs, desc, modes)
            vim.keymap.set(modes or "n", lhs, rhs, vim.tbl_extend("force", opts, {
              desc = desc,
            }))
          end

          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>gd", vim.lsp.buf.definition, "Go to definition")
          map("<leader>gD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>gi", vim.lsp.buf.implementation, "Go to implementation")
          map("<leader>gr", vim.lsp.buf.references, "References")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
          map("<C-k>", vim.lsp.buf.signature_help, "Signature help", "i")
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        underline = true,
        signs = true,
        virtual_text = {
          spacing = 2,
          source = "if_many",
        },
        float = {
          border = "rounded",
          source = true,
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = servers,
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "black",
          "isort",
          "shfmt",
          "prettier",
          "debugpy",
          "delve",
          "jdtls",
          "java-debug-adapter",
          "java-test",
          "systemd-lsp",
        },
        auto_update = false,
        run_on_start = true,
        start_delay = 1500,
        debounce_hours = 24,
      })

      -- systemd-lsp is installed by mason-tool-installer rather than
      -- mason-lspconfig. nvim-lspconfig provides the systemd_lsp config.
      vim.lsp.enable("systemd_lsp")
    end,
  },
}
