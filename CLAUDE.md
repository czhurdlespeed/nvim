# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Neovim configuration (Lua), namespaced `czhurdlespeed` and derived from ThePrimeagen's config. There is no build, test, or repo-level lint step — "running" it means launching `nvim` and editing the Lua files in place. Linting/formatting happen *inside* the editor (ALE + LSP), not from the shell.

## Applying config changes

There is no build pipeline. To apply edits, reload the affected Lua file in a running Neovim:

- `:so` (or `:source %`) — re-source the current file. `<leader><leader>` is mapped to do this.
- Restart `nvim` for changes to load order, `set.lua` options, or `after/plugin/` files that register autocmds/keymaps at source time.

## Managing plugins (Packer)

Plugins are declared in `lua/czhurdlespeed/packer.lua` and managed by `wbthomason/packer.nvim`. This file is **not** in the startup `require` chain — it's sourced manually when you edit it. The actual startup loader is the generated `plugin/packer_compiled.lua` (do not hand-edit it).

After editing `packer.lua`:
1. `:so` the file (or `<leader><leader>`).
2. `:PackerSync` — install/update/clean to match the declarations. (`:PackerInstall`, `:PackerUpdate`, `:PackerClean`, `:PackerCompile` are also available.)

`:PackerCompile` regenerates `plugin/packer_compiled.lua`.

## Load order & architecture

Startup flows through an explicit `require` chain, then Neovim auto-sources per-plugin files:

1. `init.lua` → `require("czhurdlespeed")`
2. `lua/czhurdlespeed/init.lua` requires, in order: `set` → `remap` → `lsp` → `cmp-setup`.
3. Neovim auto-sources every file in `after/plugin/*.lua` after plugins load.

The two config directories have distinct roles:

- **`lua/czhurdlespeed/`** — core, explicitly required:
  - `set.lua` — global `vim.opt` options (leader is `Space`; `colorcolumn=80`, 4-space expandtab, `foldmethod=marker`, `clipboard=unnamedplus`, undofile in `~/.vim/undodir`, node host via Volta, perl provider disabled).
  - `remap.lua` — global, plugin-independent keymaps.
  - `lsp.lua` — LSP server setup (see below).
  - `cmp-setup.lua` — `nvim-cmp` completion + LuaSnip.
  - `packer.lua` — plugin declarations (sourced manually, see above).
- **`after/plugin/*.lua`** — one file per plugin, each owning that plugin's `setup()` and its keymaps (telescope, harpoon, treesitter, fugitive, trouble, zenmode, cloak, refactoring, undotree, copilot, scope, colors).

### LSP (important: not lsp-zero despite the dependency)

`lsp-zero.nvim` is listed in `packer.lua` but its setup is **not** used. LSP is configured directly in `lua/czhurdlespeed/lsp.lua` with the native Neovim 0.11+ API: a `servers` table is iterated through `vim.lsp.config(name, cfg)` + `vim.lsp.enable(name)`. Active servers: `ty` (Python type-check), `ruff` (Python lint/format), `vtsls`, `gopls`, `clangd`, `rust_analyzer`. `after/plugin/lsp.lua` is intentionally empty.

Two autocmds in `lsp.lua` matter:
- On `LspAttach`, `ruff`'s hover is disabled so `ty` wins hover for Python.
- `BufWritePre` formats `*.py,*.go,*.rs,*.c,*.cpp,*.h,*.hpp` via `vim.lsp.buf.format`, preferring the `ruff` client for Python.

### Formatting & linting (dual system)

Formatting is split between ALE and LSP — be aware which owns a filetype before changing format behavior:

- **ALE** (`dense-analysis/ale`, configured inline in `packer.lua`) with `ale_fix_on_save = 1`: handles JS/TS, CSS, HTML, JSON, Markdown via `prettier`/`eslint`, and Python via `ruff`/`ruff_format`. Linters are restricted (`ale_linters_explicit = 1`) to `ruff` (python), `eslint` (js), `marksman` (markdown).
- **LSP** `BufWritePre` autocmd (above): handles Python/Go/Rust/C/C++ formatting.

Python is therefore touched by both ALE and the LSP path (both via Ruff). Recent history (`fix(python lsp)`, `fix(csv)`) shows this area is actively tuned — change it deliberately.

## Gotchas (dangling references that will error if triggered)

- `after/plugin/zenmode.lua` calls `ColorMyPencils()` in the `<leader>zz` / `<leader>zZ` maps, but that function is **not defined** anywhere in this config (it exists in ThePrimeagen's upstream `colors.lua` but was not copied). Those zen-mode toggles error until it's defined.
- `lua/czhurdlespeed/remap.lua` maps `<leader>vwm` / `<leader>svwm` to `require("vim-with-me")`, but `vim-with-me` is **not** declared in `packer.lua`. Those maps error if invoked.
- `cellular-automaton.nvim` is installed but has no keymap or config.
