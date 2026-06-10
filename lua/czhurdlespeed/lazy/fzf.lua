-- Grep that does NOT honor .gitignore, so nested/sub git repos (e.g. a
-- gitignored `learn/` with its own `.git`) are searched. `--no-ignore-vcs`
-- disables only VCS ignore files (.gitignore/.git/info/exclude); hidden
-- dot-dirs (.git, .venv) stay excluded since `--hidden` is not set.
local grep_rg_opts = table.concat({
  "--column --line-number --no-heading --color=always --smart-case --max-columns=4096",
  "--no-ignore-vcs",
  "-e",
}, " ")

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "echasnovski/mini.icons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>pf", function() require("fzf-lua").files() end, desc = "Find files" },
      { "<C-p>", function() require("fzf-lua").git_files() end, desc = "Git files" },
      { "<leader>ps", function() require("fzf-lua").live_grep({ rg_opts = grep_rg_opts }) end, desc = "Live grep" },
      { "<leader>pws", function() require("fzf-lua").grep_cword({ rg_opts = grep_rg_opts }) end, desc = "Grep word under cursor" },
      { "<leader>vh", function() require("fzf-lua").helptags() end, desc = "Help tags" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Buffers" },
      { "<leader>fd", function() require("fzf-lua").diagnostics_document() end, desc = "Document diagnostics" },
      { "<leader>fr", function() require("fzf-lua").resume() end, desc = "Resume last picker" },
      { "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end, desc = "Document symbols" },
      { "<leader>fS", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "Workspace symbols" },
    },
    opts = {},
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)
      -- Use fzf-lua for vim.ui.select (code actions, refactoring prompts, etc.)
      fzf.register_ui_select()
    end,
  },
}
