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
        on_highlights = function(highlights, colors)
          highlights.NonText = { fg = "#00FF00", bold = true }
          highlights.Whitespace = { fg = "#00FF00", bold = true }
          highlights.SpecialKey = { fg = "#00FF00", bold = true }
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

      vim.cmd.colorscheme("tokyonight-night")

      -- Keep the green whitespace markers across any colorscheme change.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "NonText", { fg = "#00FF00", bold = true })
          vim.api.nvim_set_hl(0, "Whitespace", { fg = "#00FF00", bold = true })
          vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#00FF00", bold = true })
        end,
      })

      vim.opt.showbreak = "↪ "
    end,
  },
}
