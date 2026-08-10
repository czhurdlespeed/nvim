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

-- Volta's shim dir sits first on PATH, and `~/.volta/bin/tree-sitter` only
-- resolves when the *current project* depends on tree-sitter-cli. Anywhere else
-- it hard-errors ("Volta error: Could not locate executable `tree-sitter` in
-- your project") instead of falling through to the standalone binary, which
-- fails every parser that needs `tree-sitter generate` (matlab, php, ...).
-- Prepend an nvim-owned bin dir containing a symlink to the first non-Volta
-- tree-sitter on PATH — shadows only that one shim, leaving volta's node/npm
-- and every other shim untouched.
local function prefer_standalone_tree_sitter_cli()
  local bin = vim.fn.stdpath("data") .. "/bin"
  local link = bin .. "/tree-sitter"
  if vim.uv.fs_stat(link) == nil then
    -- broken leftover symlink: fs_stat follows, fs_lstat doesn't
    if vim.uv.fs_lstat(link) ~= nil then
      vim.uv.fs_unlink(link)
    end
    local target
    for dir in vim.gsplit(vim.env.PATH or "", ":", { trimempty = true }) do
      if not dir:find("/.volta/", 1, true) then
        local candidate = dir .. "/tree-sitter"
        if vim.fn.executable(candidate) == 1 then
          target = candidate
          break
        end
      end
    end
    -- no real CLI installed; `brew install tree-sitter-cli` and restart
    if not target then
      return
    end
    vim.fn.mkdir(bin, "p")
    vim.uv.fs_symlink(target, link)
  end
  -- idempotent: re-sourcing this file must not stack duplicate entries
  if not vim.startswith(vim.env.PATH or "", bin .. ":") then
    vim.env.PATH = bin .. ":" .. vim.env.PATH
  end
end

-- run at spec-import time, i.e. before lazy installs/builds anything
prefer_standalone_tree_sitter_cli()

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

      -- `*.mdx` gets its own `mdx` filetype (see set.lua) but there is no `mdx`
      -- parser — `vim.treesitter.start` would look one up, fail, and the pcall
      -- below swallows it, leaving MDX files completely uncolored. Register the
      -- markdown parser for the mdx filetype so treesitter (and render-markdown)
      -- highlight it as markdown.
      vim.treesitter.language.register("markdown", "mdx")

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
