local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.ensure_installed({
    'rust_analyzer',
    'clangd',
    'pylsp',         
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

for _, group in ipairs(vim.fn.getcompletion("@lsp","highlight")) do 
    vim.api.nvim_set_hl(0,group,{})
end

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.configure('pylsp', {
    settings = {
        pylsp = {
            configurationSources = {},
            skip_token_initialization = true,  -- Add this to fix progress reporting warning
            plugins = {
                black = {
                    enabled = false,
                },
                pycodestyle = {
                    enabled = false,
                },
                jedi_completion = {enabled = true},
                jedi_hover = {enabled = true},
                jedi_references = {enabled = true},
                jedi_signature_help = {enabled = true},
                jedi_symbols = {enabled = true},
            }
        }
    }
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {"*.py", "*.js", "*.jsx", "*.ts", "*.tsx", "*.cpp", "*.c", "*.rs"},
    callback = function()
        -- Check if the file is a CSV
        local filename = vim.api.nvim_buf_get_name(0)
        if string.match(filename, "%.csv$") then
            -- Just save the file without formatting if it's a CSV
            vim.cmd('write')
            return
        end
        
        -- Write the buffer first to save your changes
        vim.cmd('write')
        
        local filetype = vim.bo.filetype
        
        -- Store cursor position
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        if filetype == "python" then
            vim.fn.system(string.format('isort --profile black --line-length 80 "%s"', filename))
            vim.fn.system(string.format('black --line-length=80 --fast --quiet "%s"', filename))
        elseif filetype == "javascript" or filetype == "typescript" or filetype == "typescriptreact" or filetype == "javascriptreact" then
            vim.fn.system(string.format('prettier --write --print-width 80 "%s"', filename))
        elseif filetype == "cpp" or filetype == "c" then
            vim.fn.system(string.format('clang-format -i --style="{BasedOnStyle: Google, ColumnLimit: 80}" "%s"', filename))
        end
        
        -- Read the file back and maintain syntax highlighting
        vim.cmd('edit')
        
        -- Restore cursor position
        vim.api.nvim_win_set_cursor(0, cursor_pos)
        
        -- Force syntax refresh
        vim.cmd('syntax enable')
    end,
})

-- Handle Lua files separately
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.lua",
    callback = function()
        if vim.fn.executable('stylua') == 1 then
            local filename = vim.api.nvim_buf_get_name(0)
            vim.fn.system(string.format('stylua --column-width 80 "%s"', filename))
        end
    end,
})

-- Add a keymap for manual formatting (add with your other keymaps)
vim.keymap.set("n", "<leader>bf", function()
    vim.lsp.buf.format({ async = false })
end, { noremap = true, desc = "Format with Black" })

lsp.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}
    
    -- Your existing keymaps
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    
end)

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = true,
        virtual_text = true,
        signs = true,
        underline = true,
        severity_sort = true,
        delay = 100,  -- Delay in milliseconds before showing diagnostics
    }
)

vim.o.updatetime = 100

lsp.setup()

require('lspconfig').ruff.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
    end,
    init_options = {
        settings = {
            args = {
                "--line-length=100"
            }
        }
    }
})
