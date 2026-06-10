return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "find/format" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "git hunk" },
        { "<leader>p", group = "project/paste" },
        { "<leader>r", group = "refactor/rename" },
        { "<leader>t", group = "test/tab" },
        { "<leader>x", group = "trouble/diagnostics" },
        { "<leader>z", group = "zen" },
        { "<leader>d", group = "debug" },
      },
    },
  },
}
