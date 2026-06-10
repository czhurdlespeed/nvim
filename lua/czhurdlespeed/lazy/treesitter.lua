-- nvim-treesitter `main` branch (the actively-developed rewrite).
--
-- Why not `master`? master is locked and only supported on Neovim <= 0.11. On
-- 0.12 its query directives crash (`attempt to call method 'range' (a nil
-- value)`) because 0.12 removed the `{ all = false }` directive option, so a
-- directive's `match[capture_id]` is now always a TSNode[] list, not a node —
-- which blows up render-markdown's markdown injection parsing.
--
-- The `main` API is a full rewrite, treated as a different plugin:
--   * no `require("nvim-treesitter.configs").setup` / `ensure_installed` /
--     `auto_install` / `highlight = { enable = true }`.
--   * parsers are installed via `require("nvim-treesitter").install(...)`.
--   * highlighting is Neovim-native: `vim.treesitter.start()` per buffer.
--   * textobjects move/select are explicit keymaps onto its module functions.
-- Requires Neovim 0.12+, a C compiler, and tree-sitter-cli (>= 0.26.1).

local ensure_installed = {
  "vimdoc", "lua", "c", "cpp", "rust", "go", "python",
  "javascript", "typescript", "tsx", "html", "css", "scss",
  "json", "yaml", "graphql", "markdown", "markdown_inline",
  "bash", "php", "matlab",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- main does NOT support lazy-loading; load at startup. build keeps the
    -- installed parsers in lockstep with the plugin (mandatory on main).
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Install only the parsers we don't yet have. Calling install() on
      -- already-present parsers re-downloads them (delete-then-fetch), which
      -- churns on every startup and can leave a parser wiped if the session
      -- exits mid-download. Updates to installed parsers are handled by the
      -- `build = ":TSUpdate"` hook, not here. On the very first launch a
      -- freshly-opened buffer may render unhighlighted until install finishes —
      -- reopen the file once parsers land.
      local installed = {}
      for _, lang in ipairs(require("nvim-treesitter.config").get_installed("parsers")) do
        installed[lang] = true
      end
      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, ensure_installed)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      -- `jsonc` is not its own parser on the `main` branch (it was only ever an
      -- alias for the json grammar). Map the jsonc filetype to the json parser
      -- so JSONC files (tsconfig.json, .vscode/*, etc.) still highlight.
      vim.treesitter.language.register("json", "jsonc")

      -- Enable native treesitter highlighting for any buffer whose language
      -- has an installed parser. pcall swallows the error for filetypes
      -- without one (e.g. plain `text`).
      local function start(buf)
        pcall(vim.treesitter.start, buf)
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("czhurdlespeed_ts_highlight", { clear = true }),
        callback = function(args)
          start(args.buf)
        end,
      })
      -- Cover buffers already loaded before this config ran (lazy=false still
      -- loads after the initial file's FileType for `nvim <file>` in some paths).
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          start(buf)
        end
      end

      vim.cmd("hi! @comment guifg=#ffffff gui=italic")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      -- select (visual/operator-pending)
      local selects = {
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        aa = "@parameter.outer",
        ia = "@parameter.inner",
      }
      for lhs, capture in pairs(selects) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(capture, "textobjects")
        end, { desc = "Select " .. capture })
      end

      -- move (normal/visual/operator-pending)
      local moves = {
        goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
      }
      for fn, maps in pairs(moves) do
        for lhs, capture in pairs(maps) do
          vim.keymap.set({ "n", "x", "o" }, lhs, function()
            move[fn](capture, "textobjects")
          end, { desc = fn .. " " .. capture })
        end
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
