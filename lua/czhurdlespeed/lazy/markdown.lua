return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    ft = { "markdown", "mdx" },
    opts = {
      file_types = { "markdown", "mdx" },
      -- No latex parser / utftex / latex2text installed, so it can't render.
      latex = { enabled = false },
    },
  },
}
