return {
  -- mason.nvim as its own spec so :Mason / :MasonInstall / ... are available
  -- immediately on startup. (As only an lspconfig dependency it would load lazily
  -- on BufReadPre/BufNewFile, so bare `nvim` with no file wouldn't have :Mason.)
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Per-server settings. mason-lspconfig (automatic_enable) calls vim.lsp.enable()
      -- for installed servers, so we only need vim.lsp.config() to attach settings.
      -- NOTE: rust is handled by rustaceanvim (see neotest.lua) — do NOT add rust_analyzer here.
      local servers = {
        ruff = {
          init_options = { settings = { fixAll = true, organizeImports = true } },
        },
        vtsls = {},
        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = true },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy" },
        },
        -- Web
        tailwindcss = {},
        cssls = {},
        html = {},
        emmet_language_server = {
          filetypes = {
            "html", "css", "scss", "less",
            "javascript", "javascriptreact",
            "typescript", "typescriptreact",
            "svelte", "vue",
          },
        },
        -- NOTE: mdx_analyzer is intentionally NOT enabled here. It wraps tsserver
        -- and crashes (exit 1) unless the project provides a TypeScript SDK.
        -- MDX is covered by treesitter + prettier (conform) + render-markdown +
        -- nvim-ts-autotag. Re-enable per-project if you need JSX-in-MDX intellisense.
        eslint = {
          settings = { workingDirectories = { mode = "auto" } },
        },
        marksman = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim", "ColorMyPencils" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
      }

      for name, cfg in pairs(servers) do
        cfg.capabilities = capabilities
        vim.lsp.config(name, cfg)
      end

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        -- Disable blanket auto-enable: it would enable EVERY mapped mason package
        -- that happens to be installed (e.g. legacy ts_ls/pylsp/rust_analyzer, or
        -- stylua's --lsp mode), causing duplicate clients. We enable explicitly below.
        automatic_enable = false,
      })

      -- Enable exactly the servers we configured. rust is intentionally absent —
      -- rustaceanvim owns rust-analyzer (see neotest.lua).
      for name in pairs(servers) do
        vim.lsp.enable(name)
      end

      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettierd",
          "stylua",
          "debugpy",
          "delve",
          "codelldb",
          "shellcheck",
          "shfmt",
          "markdownlint",
          "rustywind",
        },
      })

      -- ty (astral type checker) isn't always in the mason registry; enable it
      -- only if its binary is on PATH, with the workspace diagnostic setting.
      if vim.fn.executable("ty") == 1 then
        vim.lsp.config("ty", {
          capabilities = capabilities,
          settings = { ty = { diagnosticMode = "workspace" } },
        })
        vim.lsp.enable("ty")
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("czhurdlespeed_lsp_attach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Let ty own hover for Python (disable ruff's hover).
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          -- ESLint: fix all on save for this buffer.
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              command = "silent! EslintFixAll",
            })
          end

          -- Extra keymaps (Neovim 0.11 already provides grn/gra/grr/gri/K/gO).
          local fzf = require("fzf-lua")
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "gd", fzf.lsp_definitions, opts)
          vim.keymap.set("n", "gr", fzf.lsp_references, opts)
          vim.keymap.set("n", "gi", fzf.lsp_implementations, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        end,
      })
    end,
  },
}
