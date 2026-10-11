-- Lazy keys, so harpoon loads on first use instead of at startup
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
-- <leader>1..4 jump straight to a harpoon slot
for i = 1, 4 do
  -- One map per slot
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
      -- harpoon2 needs setup() before any list() call
      require("harpoon"):setup()
      vim.cmd("highlight! TabLineFill guibg=NONE guifg=white")
    end,
  },
}
