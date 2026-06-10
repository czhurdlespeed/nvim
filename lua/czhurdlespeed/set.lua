-- Leader must be set before lazy.nvim loads so plugin `keys` specs resolve <leader>.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.opt.foldmethod = "marker"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.g.node_host_prog = vim.fn.expand("~/.volta/tools/image/packages/neovim/lib/node_modules/neovim/bin/cli.js")
vim.g.perl_host_prog = vim.fn.exepath("perl")
vim.g.loaded_perl_provider = 0

-- Treat *.mdx as its own filetype (markdown + JSX) for mdx_analyzer / render-markdown.
vim.filetype.add({ extension = { mdx = "mdx" } })

-- Claude Code integration: auto-reload buffers when files change on disk
-- (e.g. when Claude Code edits them in a tmux pane) so we never clobber its edits.
vim.opt.autoread = true
local reload_grp = vim.api.nvim_create_augroup("AutoReloadOnDiskChange", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  group = reload_grp,
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = reload_grp,
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.WARN)
  end,
})
