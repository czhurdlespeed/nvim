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

- Servers: `ruff`, `pyrefly`, `vtsls`, `gopls`, `clangd`, `tailwindcss`, `cssls`, `html`, `emmet_language_server`, `astro`, `biome`, `marksman`, `mdx_analyzer`, `lua_ls`.
- **rust is NOT here** — `rustaceanvim` (in `lazy/neotest.lua`) owns rust-analyzer + rust DAP/tests. Do not add `rust_analyzer` to `servers` (it would double-start).
- **Python types:** `pyrefly` (Meta's Rust type checker) — replaced the old `ty`. ruff still owns Python lint/format/import-organization.
- **JS/TS/JSON/CSS lint:** `biome` — **replaced ESLint** (which is fully removed). The bundled lspconfig `biome` config only attaches when a `biome.json` exists; we override `root_dir` + `workspace_required = false` so Biome attaches everywhere (using its built-in defaults when no config is present). A project `biome.json` is still discovered and honored by the binary.
- `mdx_analyzer` (mason: `mdx-analyzer`) wraps tsserver for JSX-in-MDX intellisense (hover, go-to-definition, refs). It's Volar-based, so it shares `astro`'s `prefer_project_tsdk` `before_init` (project TS, else the pinned TS5 fallback). It **also** needs a one-line node_modules patch to start at all under Node 20+ (`scripts/patch-mdx-analyzer.sh`) — see gotchas. treesitter + prettier + render-markdown + nvim-ts-autotag still cover MDX highlighting/formatting/rendering; mdx also needs a treesitter parser alias (see treesitter gotcha).
- On `LspAttach`: ruff's hover is disabled (so `pyrefly` wins), and `gd`/`gr`/`gi`/`<leader>ca`/`<leader>rn`/`<leader>e` are mapped (0.11 already provides `grn`/`gra`/`grr`/`gri`/`K`). `gd`/`gr`/`gi` are **capability-guarded** via `vim.lsp.get_clients({ method = ... })` — if no attached server provides the method (e.g. tailwindcss is the lone client on a markdown/mdx buffer) they soft-`notify` instead of throwing "server does not support textDocument/definition".

### Completion, formatting, linting

- **Completion:** `blink.cmp` pinned to `version = "1.*"` (v2 is breaking/in-dev), with LuaSnip + friendly-snippets. (`lazy/completion.lua`)
- **Formatting:** `conform.nvim` (`lazy/formatting.lua`), format-on-save via **biome** (js/ts/jsx/tsx/css/json/jsonc), **prettierd** (scss/less/html/yaml/md/mdx/graphql), **ruff** (python — order is `ruff_fix` → `ruff_organize_imports` → `ruff_format`, i.e. fixes/imports before format per Astral guidance), stylua, gofumpt, rustfmt, clang-format. **csv is explicitly never formatted** (preserved from the original config).
- **Linting:** `nvim-lint` (`lazy/linting.lua`) covers only gaps (shellcheck, markdownlint); JS/TS/web linting is owned by the **Biome LSP**. ALE is fully removed.

### Other subsystems

- **Git:** `vim-fugitive` (power ops + `<leader>g*` maps in fugitive buffers), `gitsigns.nvim` (`]c`/`[c`, `<leader>h*` hunks, `<leader>gb` blame toggle), `lazygit.nvim` (`<leader>gg`).
- **Web dev:** tailwindcss/cssls/html/biome/emmet LSPs, `nvim-ts-autotag` (JSX/TSX/HTML tag auto-close/rename), `nvim-colorizer.lua` (`catgoose/` fork — color swatches). Tailwind class sorting: in biome-formatted files it requires Biome's nursery `useSortedClasses` rule opted into per-project in `biome.json` (can't be forced globally); in prettierd-handled filetypes it comes from per-project `prettier-plugin-tailwindcss`; `rustywind` is the global fallback.
- **Navigation/UI:** `fzf-lua` (finder; `<leader>pf`, `<C-p>`, `<leader>ps`, etc. — also the `vim.ui.select` handler), `harpoon` v2 (`<leader>a` add, `<C-e>` menu, `<leader>1..4` select), `which-key`, `lualine`, `trouble.nvim` v3 (`<leader>x*`).
- **Debug/test:** `nvim-dap` + dap-ui (`<leader>d*`) with debugpy (Python) and delve (Go); `neotest` (`<leader>t*`) with python/golang adapters + rustaceanvim for rust. **codelldb** (C/C++/rust step-debugging) is gated on existence — if its mason download failed, run `:MasonInstall codelldb` and `dap.lua` picks it up automatically.
- **tmux:** `vim-tmux-navigator` (`<C-h/j/k/l>` across nvim/tmux). System config lives outside this repo: `~/.config/tmux/tmux.conf` and `~/.local/bin/tmux-sessionizer` (revives the `<C-f>` map). The terminal must use a **Nerd Font** for icons.

## Gotchas

- `ColorMyPencils()` is now defined (in `lazy/colors.lua`) as a transparent-bg toggle used by zen-mode — it was referenced but undefined in the old config.
- `refactoring.nvim` does a top-level `require("async")`, so `lewis6991/async.nvim` is a required dependency (in `lazy/refactoring.lua`).
- **astro (`.astro`) tsdk:** `astro-language-server` is Volar-based and needs *classic* TypeScript (a `tsserverlibrary.js`/`typescript.js`), but its own mason dep and the volta global are the **TS7 native (Go) port**, which ships neither — so it errors `The typescript.tsdk init option is required`. `lsp.lua`'s shared `prefer_project_tsdk` `before_init` (used by both `astro` and `mdx_analyzer`) sets `init_options.typescript.tsdk`: prefer the project's own TS (`get_typescript_server_path`), else fall back to a pinned TS5 kept at `~/.local/share/nvim/ts-sdk` (a standalone `npm i typescript@^5` there — survives mason updates). If that dir is ever wiped, recreate it with `npm i typescript@^5` inside it.
- **mdx-analyzer won't start (Node 20+):** the latest `@mdx-js/language-server` (0.6.3, i.e. `:MasonUpdate` won't fix it) crashes on launch with `SyntaxError: The requested module 'vscode-uri' does not provide an export named 'default'`. Its bundled `vscode-markdown-languageservice` ships an ESM shim (`out/util/vscodeUri.js`) that *default*-imports `vscode-uri`, whose ESM build only has *named* exports (`URI`/`Utils`). Fix: **`scripts/patch-mdx-analyzer.sh`** rewrites that one line to a namespace import (`import * as uri`), which is idempotent and version-agnostic. mason wipes node_modules on reinstall, so re-run the script after any `:MasonInstall`/reinstall of `mdx-analyzer`. Without it, `mdx_analyzer` exits 1 and never attaches (the `gd` guard above then keeps it from erroring).
- nvim-treesitter (and -textobjects) are on `branch = "main"` (the rewrite) — **required for Neovim 0.12**; `master` is locked to Nvim ≤0.11 and its query directives crash on 0.12 (`attempt to call method 'range'`, e.g. via render-markdown). `main` has no `ensure_installed`/`auto_install`/`highlight.enable`: parsers install via `require("nvim-treesitter").install()` (guarded to missing-only to avoid per-startup re-download churn), and highlighting is native `vim.treesitter.start()` on a `FileType` autocmd. It needs a standalone **tree-sitter CLI** (`brew install tree-sitter-cli`) on PATH ahead of any Volta npm shim, plus a C compiler — without it, parsers that require `tree-sitter generate` fail to build. textobjects select/move are explicit keymaps onto its module functions (`select`/`move` in `treesitter.lua`). MDX has no colors on its own — `*.mdx` is its own filetype with no `mdx` parser, so `treesitter.lua` aliases it to the markdown parser via `vim.treesitter.language.register("markdown", "mdx")` (same trick as `jsonc`→`json`); highlights markdown + JSX tags, but not JS inside `{ }`.
