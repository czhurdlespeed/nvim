return {
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    -- Auto-close & auto-rename HTML/JSX/TSX tags (React/Solid/HTML).
    "windwp/nvim-ts-autotag",
    ft = {
      "html", "xml", "markdown", "mdx", "php",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "svelte", "vue", "astro",
    },
    -- mdx is its own filetype (markdown parser alias); autotag needs it mapped.
    opts = { aliases = { mdx = "html" } },
  },
  {
    -- Inline color swatches for CSS hex/rgb/hsl and Tailwind colors.
    -- (Maintained successor to brenoprata10's now-removed repo.)
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes = {
        "css", "scss", "less", "html",
        "javascript", "javascriptreact",
        "typescript", "typescriptreact",
        "vue", "svelte",
      },
      -- New-style options; tailwind lsp also reads project tailwind.config colors
      options = {
        parsers = {
          css = true,
          names = { enable = false },
          tailwind = { enable = true, lsp = true },
        },
      },
    },
  },
}
