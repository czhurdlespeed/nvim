require("tokyonight").setup({
    on_colors = function(colors)
        colors.comment = "#ffffff"
    end,
    on_highlights = function(highlights, colors)
        highlights.NonText = { fg = "#00FF00", bold = true }
        highlights.Whitespace = { fg = "#00FF00", bold = true }
        highlights.SpecialKey = { fg = "#00FF00", bold = true }
    end
})

-- Simpler autocmd without priority
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, 'NonText', { fg = "#00FF00", bold = true })
        vim.api.nvim_set_hl(0, 'Whitespace', { fg = "#00FF00", bold = true })
        vim.api.nvim_set_hl(0, 'SpecialKey', { fg = "#00FF00", bold = true })
    end,
})
