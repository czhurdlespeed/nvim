-- Smoke test for the lazy.nvim config.
-- Run: nvim --headless -c "luafile tests/smoke.lua"
-- Exits non-zero if any check fails.

local failures = 0
local function check(name, ok, msg)
  if ok then
    print(("PASS  %s"):format(name))
  else
    failures = failures + 1
    print(("FAIL  %s%s"):format(name, msg and ("  — " .. tostring(msg)) or ""))
  end
end

-- Force-load every lazy plugin so module requires work in headless mode
-- (lazy-loaded plugins aren't on the runtimepath until triggered).
local ok_cfg, Config = pcall(require, "lazy.core.config")
check("require lazy.core.config", ok_cfg)
if ok_cfg then
  pcall(function()
    require("lazy").load({ plugins = vim.tbl_keys(Config.plugins) })
  end)
end

-- 1. Key modules load
local modules = {
  "blink.cmp", "fzf-lua", "conform", "lint", "harpoon", "gitsigns",
  "trouble", "neotest", "dap", "dapui", "nvim-ts-autotag", "colorizer",
  "render-markdown", "which-key", "lualine", "nvim-surround", "nvim-autopairs",
  "nvim-treesitter", "mason", "mason-lspconfig", "luasnip",
}
for _, m in ipairs(modules) do
  local ok, err = pcall(require, m)
  check("require " .. m, ok, err)
end

-- 2. Expected LSP servers registered via vim.lsp.config
local servers = {
  "ruff", "vtsls", "gopls", "clangd", "tailwindcss", "cssls", "html",
  "emmet_language_server", "mdx_analyzer", "eslint", "marksman", "lua_ls",
}
for _, s in ipairs(servers) do
  local ok, cfg = pcall(function() return vim.lsp.config[s] end)
  check("vim.lsp.config[" .. s .. "]", ok and cfg ~= nil)
end

-- 3. conform resolves a formatter for each expected filetype, and NOT for csv
local conform = require("conform")
local fbf = conform.formatters_by_ft or {}
for _, ft in ipairs({ "python", "lua", "typescriptreact", "css", "scss", "html", "json", "mdx", "go", "rust", "c" }) do
  check("conform formatter for " .. ft, fbf[ft] ~= nil and #fbf[ft] > 0)
end
check("conform has NO csv formatter", fbf["csv"] == nil)

-- 4. mapleader is space
check("mapleader is <space>", vim.g.mapleader == " ")

print(("\n=== %s (%d failure%s) ==="):format(
  failures == 0 and "ALL PASSED" or "FAILURES",
  failures,
  failures == 1 and "" or "s"
))

vim.cmd(failures == 0 and "qa!" or "cq!")
