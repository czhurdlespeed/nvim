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

-- 2. is_enabled, not vim.lsp.config[]: that exists for every lspconfig server
local servers = {
  "ruff", "pyrefly", "vtsls", "gopls", "clangd", "tailwindcss", "cssls", "html",
  "emmet_language_server", "astro", "mdx_analyzer", "biome", "marksman", "lua_ls",
}
for _, s in ipairs(servers) do
  -- Proves the explicit vim.lsp.enable() loop ran for this server
  check("lsp enabled: " .. s, vim.lsp.is_enabled(s))
end
-- rustaceanvim owns rust-analyzer; ts_ls would duplicate vtsls
for _, s in ipairs({ "rust_analyzer", "ts_ls" }) do
  -- Either one enabled means duplicate clients
  check("lsp NOT enabled: " .. s, not vim.lsp.is_enabled(s))
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

-- 5. <leader>d must stay the void-delete operator, not a DAP prefix
check("<leader>d is void-delete", vim.fn.maparg("<leader>d", "n") == [["_d]])
-- A leader map that prefixes another waits timeoutlen before firing
local leader_lhs = {}
-- Global normal maps; leader shows up as a literal space
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
  -- Only leader maps were part of the clash cleanup
  if vim.startswith(m.lhs, " ") then
    -- Collected for the pairwise prefix scan below
    table.insert(leader_lhs, m.lhs)
  end
end
-- Every (shorter, longer) pair where one is a strict prefix of the other
local clashes = {}
-- O(n^2) is fine for ~60 maps
for _, a in ipairs(leader_lhs) do
  -- Compare against every other leader map
  for _, b in ipairs(leader_lhs) do
    -- Strict prefix only; a map never clashes with itself
    if a ~= b and vim.startswith(b, a) then
      -- Human-readable pair for the failure message
      table.insert(clashes, vim.fn.keytrans(a) .. " < " .. vim.fn.keytrans(b))
    end
  end
end
-- Lists the offending pairs on failure
check("no leader prefix clashes", #clashes == 0, table.concat(clashes, ", "))

print(("\n=== %s (%d failure%s) ==="):format(
  failures == 0 and "ALL PASSED" or "FAILURES",
  failures,
  failures == 1 and "" or "s"
))

vim.cmd(failures == 0 and "qa!" or "cq!")
