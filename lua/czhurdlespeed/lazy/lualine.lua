return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_b = {
          "branch",
          {
            -- Reuse gitsigns' per-buffer counts instead of lualine's own git jobs.
            "diff",
            source = function()
              local g = vim.b.gitsigns_status_dict
              if g then
                return { added = g.added, modified = g.changed, removed = g.removed }
              end
            end,
          },
          "diagnostics",
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
      },
      extensions = { "fugitive", "fzf", "lazy", "quickfix", "trouble", "nvim-dap-ui" },
    },
  },
}
