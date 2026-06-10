return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", vim.cmd.Git, desc = "Git status (fugitive)" },
    },
    config = function()
      local grp = vim.api.nvim_create_augroup("czhurdlespeed_fugitive", {})
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = grp,
        pattern = "*",
        callback = function()
          if vim.bo.ft ~= "fugitive" then
            return
          end
          local bufnr = vim.api.nvim_get_current_buf()
          local opts = { buffer = bufnr, remap = false }
          vim.keymap.set("n", "<leader>gp", function() vim.cmd.Git("push") end, opts)
          vim.keymap.set("n", "<leader>gP", function() vim.cmd.Git({ "pull", "--rebase" }) end, opts)
          vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", opts)
          vim.keymap.set("n", "<leader>ga", ":Git add .", opts)
          vim.keymap.set("n", "<leader>gA", ":Git add -u", opts)
          vim.keymap.set("n", "<leader>gr", ":Git reset ", opts)
          vim.keymap.set("n", "<leader>gc", ":Git commit ", opts)
          vim.keymap.set("n", "<leader>gl", ":Git log ", opts)
          vim.keymap.set("n", "<leader>gR", ":Git reset HEAD~ ", opts)
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "Next git hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Prev git hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle line blame")
      end,
    },
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
