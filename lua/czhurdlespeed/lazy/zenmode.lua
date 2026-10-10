return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      {
        "<leader>zz",
        function()
          -- window.options apply only to the zen float, so nothing leaks back
          -- onto the original window when zen closes.
          require("zen-mode").setup({
            window = { width = 90, options = { wrap = false, number = true, relativenumber = true } },
          })
          require("zen-mode").toggle()
          ColorMyPencils()
        end,
        desc = "Zen mode (numbers)",
      },
      {
        "<leader>zZ",
        function()
          require("zen-mode").setup({
            window = {
              width = 80,
              options = { wrap = false, number = false, relativenumber = false, colorcolumn = "" },
            },
          })
          require("zen-mode").toggle()
          ColorMyPencils()
        end,
        desc = "Zen mode (minimal)",
      },
    },
  },
}
