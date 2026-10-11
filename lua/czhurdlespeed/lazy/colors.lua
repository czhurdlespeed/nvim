return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        on_colors = function(colors)
          colors.comment = "#ffffff"
        end,
      })

      -- ColorMyPencils: transparent-background toggle used by zen-mode.
      -- (Was referenced but never defined in the old config — defining it here.)
      function ColorMyPencils(color)
        color = color or "tokyonight-night"
        vim.cmd.colorscheme(color)
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      end

      -- Before the first :colorscheme, so startup gets the green markers too
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "NonText", { fg = "#00FF00", bold = true })
          vim.api.nvim_set_hl(0, "Whitespace", { fg = "#00FF00", bold = true })
          vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#00FF00", bold = true })
        end,
      })

      -- Fires the ColorScheme autocmd above
      vim.cmd.colorscheme("tokyonight-night")

      vim.opt.showbreak = "↪ "
    end,
  },
}
