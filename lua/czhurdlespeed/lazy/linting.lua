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
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
