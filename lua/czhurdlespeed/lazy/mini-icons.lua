-- Icon provider for the whole config. mini.icons is faster and has richer
-- filetype/LSP-kind/extension coverage than nvim-web-devicons, and is the
-- provider folke's plugins (which-key, trouble, etc.) now prefer.
--
-- The `init` preload makes mini.icons satisfy any `require("nvim-web-devicons")`
-- (lualine, fzf-lua, render-markdown still ask for it by name), so the legacy
-- plugin can be dropped entirely while everything keeps its icons.
return {
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
