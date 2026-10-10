return {
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		-- Not ]t/[t: those are 0.12's built-in :tnext/:tprevious.
		keys = {
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todos (Trouble)" },
			{ "<leader>pt", "<cmd>TodoFzfLua<cr>", desc = "Todos (fzf)" },
		},
	},
}
