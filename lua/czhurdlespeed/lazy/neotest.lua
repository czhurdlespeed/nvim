return {
  {
    -- Modern Rust setup: bundles rust-analyzer config, DAP, and test/runnables.
    -- Replaces a manual rust_analyzer LSP block (do NOT also configure it in lsp.lua).
    "mrcjkb/rustaceanvim",
    lazy = false,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "fredrikaverpil/neotest-golang",
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Test nearest" },
      { "<leader>tR", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
      { "<leader>tw", function() require("neotest").watch.toggle() end, desc = "Test watch" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python"),
          require("neotest-golang"),
        },
      })
    end,
  },
}
