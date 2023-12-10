require("scope").setup({
    hooks = {
        on_open = function()
            vim.cmd("setlocal foldmethod=expr")
            vim.cmd("setlocal foldexpr=nvim_treesitter#foldexpr()")
        end,
    },
})
    -- vim keyboard shortcuts for :bnext and :bprev  
    vim.keymap.set("n", "<leader>th", ":tabprevious<CR>")
    vim.keymap.set("n", "<leader>tl", ":tabnext<CR>")
    vim.keymap.set("n", "<leader>tn", ":tabnew<CR>")


