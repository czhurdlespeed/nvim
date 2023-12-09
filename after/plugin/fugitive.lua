vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

local ThePrimeagen_Fugitive = vim.api.nvim_create_augroup("ThePrimeagen_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = ThePrimeagen_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>gp", function()
            vim.cmd.Git('push')
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>gP", function()
            vim.cmd.Git({'pull',  '--rebase'})
        end, opts)

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", opts);

        -- NOTE: Git add to staging area
        vim.keymap.set("n", "<leader>ga", ":Git add .", opts);
        -- NOTE: Git add modified files to staging area
        vim.keymap.set("n", "<leader>gA", ":Git add -u", opts);
        -- NOTE: Git reset 
        vim.keymap.set("n", "<leader>gr", ":Git reset ", opts);
        -- NOTE: Git commit
        vim.keymap.set("n", "<leader>gc", ":Git commit ", opts);
        -- NOTE: Git status
        vim.keymap.set("n", "<leader>gs", ":Git ", opts);
        -- NOTE: Git log
        vim.keymap.set("n", "<leader>gl", ":Git log ", opts);
        -- NOTE: Git remove a local commit
        vim.keymap.set("n", "<leader>gR", ":Git reset HEAD~ ", opts);
    end,
})
