return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      {
        "<leader>zz",
        function()
          -- window.options apply to the zen float only, so nothing leaks on close
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
          -- Same scoping; the ruler is cleared only inside the float
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
