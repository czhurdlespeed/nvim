return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "Format buffer/selection",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Fixes + import organization run BEFORE formatting (Astral guidance):
				-- lint fixes can change structure, which the formatter then cleans up.
				python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
				javascript = { "biome" },
				javascriptreact = { "biome" },
				typescript = { "biome" },
				typescriptreact = { "biome" },
				css = { "biome" },
				json = { "biome" },
				jsonc = { "biome" },
				scss = { "prettierd" },
				less = { "prettierd" },
				html = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				mdx = { "prettierd" },
				graphql = { "prettierd" },
				go = { "gofumpt" },
				rust = { "rustfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			-- Biome formats js/ts/jsx/tsx/css/json. Tailwind class sorting comes from
			-- Biome's nursery `useSortedClasses` rule, opted into per-project in biome.json
			-- (it can't be forced globally). prettier-plugin-tailwindcss still sorts in the
			-- prettierd-handled filetypes; rustywind is the global fallback.
			format_on_save = function(bufnr)
				-- Never reformat csv files (preserve original behavior).
				if vim.bo[bufnr].filetype == "csv" then
					return
				end
				return { timeout_ms = 1000, lsp_format = "fallback" }
			end,
		},
	},
}
