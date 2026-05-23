-- Capabilities from nvim-cmp so completion works
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
  ty = {
    settings = { ty = { diagnosticMode = 'workspace' } },
  },
  ruff = {
    init_options = {
      settings = { fixAll = true, organizeImports = true },
    },
  },
  vtsls = {},          -- or use ts_ls = {}
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
    cmd = { 'clangd', '--background-index', '--clang-tidy' },
  },
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = 'clippy' },
      },
    },
  },
}

for name, cfg in pairs(servers) do
  cfg.capabilities = capabilities
  vim.lsp.config(name, cfg)
  vim.lsp.enable(name)
end

-- Disable ruff's hover so ty wins
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Format on save for languages NOT handled by ALE
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.py', '*.go', '*.rs', '*.c', '*.cpp', '*.h', '*.hpp' },
  callback = function()
    vim.lsp.buf.format({
      filter = function(client)
        -- prefer ruff for python formatting
        if vim.bo.filetype == 'python' then return client.name == 'ruff' end
        return true
      end,
    })
  end,
})
