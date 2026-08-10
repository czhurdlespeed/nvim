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
			"yioneko/nvim-vtsls",
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- nvim-vtsls supplies the :VtsExec/:VtsRename commands and TS-specific
			-- helpers (select_ts_version, goto_source_definition, ...). Guarded so a
			-- load failure degrades to a plain vtsls setup instead of breaking the
			-- other servers configured below.
			local ok_vtsls, vtsls = pcall(require, "vtsls")

			-- Volar-based servers (astro-language-server, mdx-analyzer) wrap tsserver and
			-- need a *classic* TypeScript SDK (tsserverlibrary.js/typescript.js). Prefer the
			-- project's own TS so diagnostics match its version; else fall back to the pinned
			-- TS5 at ~/.local/share/nvim/ts-sdk (survives mason updates; recreate with
			-- `npm i typescript@^5` there if wiped). Without a tsdk they error
			-- "The typescript.tsdk init option is required" and exit 1.
			local function prefer_project_tsdk(_, config)
				config.init_options = config.init_options or {}
				config.init_options.typescript = config.init_options.typescript or {}
				local ts = config.init_options.typescript
				if not ts.tsdk or ts.tsdk == "" then
					local ok, util = pcall(require, "lspconfig.util")
					local tsdk = ok and util.get_typescript_server_path(config.root_dir) or ""
					if tsdk == nil or tsdk == "" then
						tsdk = vim.fs.joinpath(vim.fn.stdpath("data"), "ts-sdk", "node_modules", "typescript", "lib")
					end
					ts.tsdk = tsdk
				end
			end

			-- Per-server settings. mason-lspconfig (automatic_enable) calls vim.lsp.enable()
			-- for installed servers, so we only need vim.lsp.config() to attach settings.
			-- NOTE: rust is handled by rustaceanvim (see neotest.lua) — do NOT add rust_analyzer here.
			local servers = {
				ruff = {
					init_options = { settings = { fixAll = true, organizeImports = true } },
				},
				-- pyrefly (Meta's Rust Python type checker) owns Python types/hover.
				-- Replaces the old `ty` setup. ruff handles lint+format/imports.
				pyrefly = {},
				-- vim.lsp.config merges this over nvim-lspconfig's bundled lsp/vtsls.lua
				-- (which supplies cmd/filetypes/root_dir), so only settings go here.
				-- autoUseWorkspaceTsdk: prefer the project's node_modules/typescript so
				-- diagnostics match the version it builds with, else the bundled TS.
				-- (:VtsExec/:VtsRename are registered by nvim-vtsls on LspAttach, not here.)
				vtsls = {
					settings = {
						typescript = { updateImportsOnFileMove = "always" },
						javascript = { updateImportsOnFileMove = "always" },
						vtsls = {
							autoUseWorkspaceTsdk = true,
							enableMoveToFileCodeAction = true,
						},
					},
				},
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
				-- Volar-based astro-ls needs classic TS (tsserverlibrary.js/typescript.js);
				-- its own dep + the volta global are the TS7 native port, which lacks them.
				astro = {
					before_init = prefer_project_tsdk,
				},
				emmet_language_server = {
					filetypes = {
						"html",
						"css",
						"scss",
						"less",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"svelte",
						"vue",
					},
				},
				-- mdx-analyzer wraps tsserver for JSX-in-MDX intellisense (hover,
				-- go-to-definition, references). prefer_project_tsdk hands it the project's
				-- TypeScript (or the pinned TS5 fallback), so it no longer crashes on
				-- standalone .mdx files — the reason it used to be disabled. Treesitter +
				-- prettier + render-markdown + nvim-ts-autotag still cover the rest.
				mdx_analyzer = {
					before_init = prefer_project_tsdk,
				},
				-- Biome owns JS/TS/JSON/CSS linting (replaces ESLint) + formatting (via conform).
				-- The bundled lspconfig config only attaches when a biome.json exists
				-- (workspace_required + a nil-returning root_dir); override both so Biome
				-- attaches everywhere and uses its built-in defaults when no config is present.
				-- A project biome.json is still discovered + honored by the binary either way.
				biome = {
					workspace_required = false,
					root_dir = function(bufnr, on_dir)
						-- Prioritized tiers (Nvim 0.11.3+): a project biome.json/jsonc always
						-- wins as the root when present, else the package/git root, else cwd.
						on_dir(
							vim.fs.root(bufnr, { { "biome.json", "biome.jsonc" }, { "package.json" }, { ".git" } })
								or vim.fn.getcwd()
						)
					end,
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

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("czhurdlespeed_lsp_attach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					-- Let pyrefly own hover for Python (disable ruff's hover).
					if client and client.name == "ruff" then
						client.server_capabilities.hoverProvider = false
					end

					-- Extra keymaps (Neovim 0.11 already provides grn/gra/grr/gri/K/gO).
					local fzf = require("fzf-lua")
					local opts = { buffer = args.buf, silent = true }

					-- Degrade LSP navigation to a soft notify (not a hard error) on
					-- buffers whose attached server(s) don't provide the method — e.g.
					-- tailwindcss attaches to mdx/markdown for class completion but has
					-- no definition/reference/implementation provider, so a bare `gd`
					-- otherwise throws "server does not support textDocument/definition".
					local function if_supported(method, fn, label)
						return function()
							if next(vim.lsp.get_clients({ bufnr = args.buf, method = method })) then
								fn()
							else
								vim.notify("No LSP server provides " .. label .. " here", vim.log.levels.INFO)
							end
						end
					end

					vim.keymap.set("n", "gd", if_supported("textDocument/definition", fzf.lsp_definitions, "go-to-definition"), opts)
					vim.keymap.set("n", "gr", if_supported("textDocument/references", fzf.lsp_references, "references"), opts)
					vim.keymap.set("n", "gi", if_supported("textDocument/implementation", fzf.lsp_implementations, "implementations"), opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

					-- vtsls-only extras (buffer-local; <leader>V prefix is otherwise unused).
					if ok_vtsls and client and client.name == "vtsls" then
						local function vmap(lhs, cmd, desc)
							vim.keymap.set("n", lhs, function()
								vtsls.commands[cmd](0)
							end, vim.tbl_extend("force", opts, { desc = desc }))
						end
						vmap("<leader>Vv", "select_ts_version", "vtsls: select TS version")
						vmap("<leader>Vs", "goto_source_definition", "vtsls: goto source definition")
						vmap("<leader>Vo", "organize_imports", "vtsls: organize imports")
					end
				end,
			})
		end,
	},
}
