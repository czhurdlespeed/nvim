-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Run :so to source file; then you can issue :Packer commands!!!
-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use ({
      'nvim-telescope/telescope.nvim', tag = '0.1.4',
      -- or                            , branch = '0.1.x',
      requires = { {'nvim-lua/plenary.nvim'} }
  })
  use ({
      'folke/tokyonight.nvim',
      as = 'tokyonight',
      config = function()
          vim.cmd('colorscheme tokyonight-night')
      end
  })

  use({
      "folke/trouble.nvim",
      config = function()
          require("trouble").setup {
              icons = false,
          }
      end
  })

  use {
			'nvim-treesitter/nvim-treesitter',
			run = function()
				local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
				ts_update()
			end,}
  use("nvim-treesitter/playground")
  use("theprimeagen/harpoon")
  use("theprimeagen/refactoring.nvim")
  use("mbbill/undotree")
  use("tpope/vim-fugitive")
  use("nvim-treesitter/nvim-treesitter-context");

  -- Add ALE
  use {
    'dense-analysis/ale',
    config = function()
      -- ALE configuration
      vim.g.ale_linters = {
        python = {"ruff"},
        javascript = {'eslint'},
        markdown = {'marksman'},
        -- Add more languages and linters as needed
      }
      
      vim.g.ale_fixers = {
        python = {"ruff", "ruff_format"},
        javascript = {'prettier', 'eslint'},
        typescript = {'prettier', 'eslint'},
        css = {'prettier'},
        html = {'prettier'},
        json = {'prettier'},
        markdown = {'prettier'},
        -- Add more languages and fixers as needed
      }
      
      -- Enable fixing on save
      vim.g.ale_fix_on_save = 1
      
      -- Set signs for errors and warnings
      vim.g.ale_sign_error = '✘'
      vim.g.ale_sign_warning = '⚠'
      
      -- Enable completion where available
      vim.g.ale_completion_enabled = 1
      
      -- Only run linters named in ale_linters settings
      vim.g.ale_linters_explicit = 1
      
      -- Customize the error and warning format
      vim.g.ale_echo_msg_format = '[%linter%] %s [%severity%]'
      
      -- Set this variable to 1 to fix files when you save them.
      vim.g.ale_fix_on_save = 1
    end
  }
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }

  use("folke/zen-mode.nvim")
  use("github/copilot.vim") 
  use("eandrju/cellular-automaton.nvim")
  use("laytan/cloak.nvim")
  use("tiagovla/scope.nvim")
end)
