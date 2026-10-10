return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "git hunk" },
        { "<leader>p", group = "project/paste" },
        { "<leader>r", group = "refactor/rename" },
        { "<leader>t", group = "test" },
        { "<leader>x", group = "trouble/diagnostics" },
        { "<leader>z", group = "zen" },
        { "<leader>D", group = "debug" },
      },
    },
  },
}
