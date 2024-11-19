vim.opt.guicursor = ""
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak = '↪ '
vim.opt.textwidth = 80        -- Set to 80 for PEP8
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Your existing make file autocmd
vim.api.nvim_create_autocmd("FileType", {
    pattern = "make",
    callback = function()
        vim.opt_local.expandtab = false
    end
})

-- Python-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.breakindent = true
        vim.opt_local.linebreak = false      -- Changed to false to force hard breaks
        vim.opt_local.textwidth = 80         -- Strict 80 chars for Python
        vim.opt_local.formatoptions = 'tcqj' -- Auto-wrap text and comments
        vim.opt_local.colorcolumn = "80"
    end
})

-- Other file types
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"lua", "javascript", "typescript", "json"},
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.breakindent = true
        vim.opt_local.linebreak = true
        vim.opt_local.textwidth = 80
    end
})
