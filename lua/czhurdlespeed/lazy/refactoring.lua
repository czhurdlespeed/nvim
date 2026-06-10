return {
  {
    "theprimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- This build of refactoring.nvim does a top-level `require("async")`.
      "lewis6991/async.nvim",
    },
    keys = {
      -- extract_func/extract_var/inline_var set `operatorfunc` and return a "g@"
      -- string that must be fed back as keys, so these MUST be `expr = true` and
      -- `return` the call. select_refactor runs via async directly (no expr).
      { "<leader>ri", function() return require("refactoring").inline_var() end, mode = { "n", "x" }, expr = true, desc = "Inline variable" },
      { "<leader>re", function() return require("refactoring").extract_func() end, mode = "x", expr = true, desc = "Extract function" },
      { "<leader>rv", function() return require("refactoring").extract_var() end, mode = "x", expr = true, desc = "Extract variable" },
      { "<leader>rr", function() require("refactoring").select_refactor() end, mode = { "n", "x" }, desc = "Select refactor" },
    },
    opts = {},
  },
}
