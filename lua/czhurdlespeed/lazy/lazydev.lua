return {
  {
    -- Neovim API + plugin types for lua_ls while editing this config (loads
    -- only the libraries a buffer actually requires). Completion source is
    -- wired into blink in completion.lua.
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
