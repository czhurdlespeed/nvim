# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Neovim configuration (Lua) for **Neovim 0.12+**, namespaced `czhurdlespeed` and derived from ThePrimeagen's config. It uses **lazy.nvim** for plugin management. There is no build/test/lint step at the shell level — "running" it means launching `nvim`; linting/formatting happen *inside* the editor (conform + nvim-lint + LSP).

## Applying & managing changes

- `:so` (or `<leader><leader>`) re-sources the current file; restart `nvim` for changes to load order, `set.lua`, or plugin specs.
- **Plugins:** declared as one-file-per-concern specs under `lua/czhurdlespeed/lazy/`. Edit a spec, then `:Lazy sync` (install/update/clean to match). `:Lazy` opens the UI; `:Lazy check`/`:Lazy restore` use the committed `lazy-lock.json` (commit it after syncing).
- **External tools (LSP servers, formatters, linters, debug adapters):** managed by **mason** — `:Mason` UI. They're declared in `lua/czhurdlespeed/lazy/lsp.lua` (`mason-lspconfig` `ensure_installed` for servers, `mason-tool-installer` for tools) and auto-install on first launch.
- **Smoke test:** `nvim --headless -c "luafile tests/smoke.lua"` asserts every key module loads, all configured LSP servers are registered, and conform resolves formatters (csv excluded). Exits non-zero on failure.
- **Health:** `:checkhealth`.

## Load order & architecture

1. `init.lua` → `require("czhurdlespeed")`
2. `lua/czhurdlespeed/init.lua` requires, in order: `set` → `remap` → `lazy_init`.
   - `set.lua` — options. **Leader (`Space`) is set here first** (before lazy, so plugin `keys` resolve). Also: mdx filetype registration and the **Claude Code auto-reload** autocmd (`autoread` + `checktime` on focus/enter — so files Claude Code edits on disk reload instead of being clobbered).
   - `remap.lua` — global, plugin-independent keymaps.
   - `lazy_init.lua` — bootstraps lazy.nvim and loads `{ import = "czhurdlespeed.lazy" }`.
3. lazy.nvim loads every spec in `lua/czhurdlespeed/lazy/*.lua` (each returns a spec table; `config`/`opts`/`keys`/`event`/`ft` drive lazy-loading).

There is no `after/plugin/` directory — per-plugin config lives in its lazy spec. (The old Packer `after/plugin/*`, `packer.lua`, and `plugin/packer_compiled.lua` are gone.)

### LSP (`lazy/lsp.lua`) — important

Uses the native Neovim 0.11+ API: a `servers` table is applied via `vim.lsp.config(name, cfg)`, then **explicitly enabled** with a `vim.lsp.enable()` loop. mason-lspconfig's `automatic_enable` is **deliberately `false`** — leaving it on auto-enables every mapped mason package that happens to be installed (legacy `ts_ls`/`pylsp`/`rust_analyzer`, even stylua's `--lsp`), causing duplicate clients. Capabilities come from `blink.cmp`.

- Servers: `ruff`, `vtsls`, `gopls`, `clangd`, `tailwindcss`, `cssls`, `html`, `emmet_language_server`, `eslint`, `marksman`, `lua_ls`.
- **rust is NOT here** — `rustaceanvim` (in `lazy/neotest.lua`) owns rust-analyzer + rust DAP/tests. Do not add `rust_analyzer` to `servers` (it would double-start).
- `ty` (Python types) is enabled conditionally, only if the `ty` binary is on PATH.
- `mdx_analyzer` is intentionally disabled — it wraps tsserver and crashes without a project TypeScript SDK. MDX is covered by treesitter + prettier + render-markdown + nvim-ts-autotag.
- On `LspAttach`: ruff's hover is disabled (so `ty` wins), eslint runs `EslintFixAll` on save, and `gd`/`gr`/`gi`/`<leader>ca`/`<leader>rn`/`<leader>e` are mapped (0.11 already provides `grn`/`gra`/`grr`/`gri`/`K`).

### Completion, formatting, linting

- **Completion:** `blink.cmp` pinned to `version = "1.*"` (v2 is breaking/in-dev), with LuaSnip + friendly-snippets. (`lazy/completion.lua`)
- **Formatting:** `conform.nvim` (`lazy/formatting.lua`), format-on-save via **prettierd** (js/ts/jsx/tsx/css/scss/html/json/yaml/md/mdx/graphql), ruff (python), stylua, gofumpt, rustfmt, clang-format. **csv is explicitly never formatted** (preserved from the original config).
- **Linting:** `nvim-lint` (`lazy/linting.lua`) covers only gaps (shellcheck, markdownlint); JS/TS/web linting is owned by the **ESLint LSP**. ALE is fully removed.

### Other subsystems

- **Git:** `vim-fugitive` (power ops + `<leader>g*` maps in fugitive buffers), `gitsigns.nvim` (`]c`/`[c`, `<leader>h*` hunks, `<leader>gb` blame toggle), `lazygit.nvim` (`<leader>gg`).
- **Web dev:** tailwindcss/cssls/html/eslint/emmet LSPs, `nvim-ts-autotag` (JSX/TSX/HTML tag auto-close/rename), `nvim-colorizer.lua` (`catgoose/` fork — color swatches). Tailwind class sorting via per-project `prettier-plugin-tailwindcss` (prettierd auto-detects it); `rustywind` is the global fallback.
- **Navigation/UI:** `fzf-lua` (finder; `<leader>pf`, `<C-p>`, `<leader>ps`, etc. — also the `vim.ui.select` handler), `harpoon` v2 (`<leader>a` add, `<C-e>` menu, `<leader>1..4` select), `which-key`, `lualine`, `trouble.nvim` v3 (`<leader>x*`).
- **Debug/test:** `nvim-dap` + dap-ui (`<leader>d*`) with debugpy (Python) and delve (Go); `neotest` (`<leader>t*`) with python/golang adapters + rustaceanvim for rust. **codelldb** (C/C++/rust step-debugging) is gated on existence — if its mason download failed, run `:MasonInstall codelldb` and `dap.lua` picks it up automatically.
- **tmux:** `vim-tmux-navigator` (`<C-h/j/k/l>` across nvim/tmux). System config lives outside this repo: `~/.config/tmux/tmux.conf` and `~/.local/bin/tmux-sessionizer` (revives the `<C-f>` map). The terminal must use a **Nerd Font** for icons.

## Gotchas

- `ColorMyPencils()` is now defined (in `lazy/colors.lua`) as a transparent-bg toggle used by zen-mode — it was referenced but undefined in the old config.
- `refactoring.nvim` does a top-level `require("async")`, so `lewis6991/async.nvim` is a required dependency (in `lazy/refactoring.lua`).
- nvim-treesitter (and -textobjects) are on `branch = "main"` (the rewrite) — **required for Neovim 0.12**; `master` is locked to Nvim ≤0.11 and its query directives crash on 0.12 (`attempt to call method 'range'`, e.g. via render-markdown). `main` has no `ensure_installed`/`auto_install`/`highlight.enable`: parsers install via `require("nvim-treesitter").install()` (guarded to missing-only to avoid per-startup re-download churn), and highlighting is native `vim.treesitter.start()` on a `FileType` autocmd. It needs a standalone **tree-sitter CLI** (`brew install tree-sitter-cli`) on PATH ahead of any Volta npm shim, plus a C compiler — without it, parsers that require `tree-sitter generate` fail to build. textobjects select/move are explicit keymaps onto its module functions (`select`/`move` in `treesitter.lua`).
