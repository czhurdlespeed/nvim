return {
  {
    "kylechui/nvim-surround",
    version = "*",
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
      "svelte", "vue",
    },
    opts = {},
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
      user_default_options = {
        tailwind = true,
        css = true,
        names = false,
      },
    },
  },
}
