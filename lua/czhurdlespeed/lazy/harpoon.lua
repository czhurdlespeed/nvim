return {
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

      for i = 1, 4 do
        vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon file " .. i })
      end

      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon next" })

      vim.cmd("highlight! HarpoonInactive guibg=NONE guifg=#63698c")
      vim.cmd("highlight! HarpoonActive guibg=NONE guifg=white")
      vim.cmd("highlight! HarpoonNumberActive guibg=NONE guifg=#7aa2f7")
      vim.cmd("highlight! HarpoonNumberInactive guibg=NONE guifg=#7aa2f7")
      vim.cmd("highlight! TabLineFill guibg=NONE guifg=white")
    end,
  },
}
