local keys = {
  { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
  {
    "<C-e>",
    function()
      local harpoon = require("harpoon")
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    desc = "Harpoon menu",
  },
  { "<C-S-P>", function() require("harpoon"):list():prev() end, desc = "Harpoon prev" },
  { "<C-S-N>", function() require("harpoon"):list():next() end, desc = "Harpoon next" },
}
for i = 1, 4 do
  table.insert(keys, {
    "<leader>" .. i,
    function() require("harpoon"):list():select(i) end,
    desc = "Harpoon file " .. i,
  })
end

return {
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = keys,
    config = function()
      require("harpoon"):setup()
      vim.cmd("highlight! TabLineFill guibg=NONE guifg=white")
    end,
  },
}
