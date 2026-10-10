return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      -- JS/TS/web linting is owned by the Biome LSP; nvim-lint only fills gaps
      -- where there is no language server doing diagnostics.
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        markdown = { "markdownlint" },
      }

      local grp = vim.api.nvim_create_augroup("czhurdlespeed_nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = grp,
        callback = function(args)
          -- shellcheck lints the file on disk (not stdin) once it exists, so on
          -- InsertLeave with unsaved edits its diagnostics land on stale lines.
          local ft = vim.bo[args.buf].filetype
          if args.event == "InsertLeave" and vim.bo[args.buf].modified and (ft == "sh" or ft == "bash") then
            return
          end
          require("lint").try_lint()
        end,
      })
    end,
  },
}
