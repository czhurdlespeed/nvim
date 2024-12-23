require('lspconfig').ruff.setup({
    init_options = {
        settings = {
            -- Ruff language server settings
            lineLength = 80,
            fixAll = true,
            organizeImports = true,
            showSyntaxErrors = true,
            lint = {
                enable = true
            },
            format = {
                preview = true
            },
        },
    },
})
