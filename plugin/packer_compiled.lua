-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/calwetzel/.cache/nvim/packer_hererocks/2.1.1734355927/share/lua/5.1/?.lua;/Users/calwetzel/.cache/nvim/packer_hererocks/2.1.1734355927/share/lua/5.1/?/init.lua;/Users/calwetzel/.cache/nvim/packer_hererocks/2.1.1734355927/lib/luarocks/rocks-5.1/?.lua;/Users/calwetzel/.cache/nvim/packer_hererocks/2.1.1734355927/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/calwetzel/.cache/nvim/packer_hererocks/2.1.1734355927/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ale = {
    config = { "\27LJ\2\n�\5\0\0\3\0 \00096\0\0\0009\0\1\0005\1\4\0005\2\3\0=\2\5\0015\2\6\0=\2\a\0015\2\b\0=\2\t\1=\1\2\0006\0\0\0009\0\1\0005\1\f\0005\2\v\0=\2\5\0015\2\r\0=\2\a\0015\2\14\0=\2\15\0015\2\16\0=\2\17\0015\2\18\0=\2\19\0015\2\20\0=\2\21\0015\2\22\0=\2\t\1=\1\n\0006\0\0\0009\0\1\0)\1\1\0=\1\23\0006\0\0\0009\0\1\0'\1\25\0=\1\24\0006\0\0\0009\0\1\0'\1\27\0=\1\26\0006\0\0\0009\0\1\0)\1\1\0=\1\28\0006\0\0\0009\0\1\0)\1\1\0=\1\29\0006\0\0\0009\0\1\0'\1\31\0=\1\30\0006\0\0\0009\0\1\0)\1\1\0=\1\23\0K\0\1\0\31[%linter%] %s [%severity%]\24ale_echo_msg_format\25ale_linters_explicit\27ale_completion_enabled\b⚠\21ale_sign_warning\b✘\19ale_sign_error\20ale_fix_on_save\1\2\0\0\rprettier\tjson\1\2\0\0\rprettier\thtml\1\2\0\0\rprettier\bcss\1\2\0\0\rprettier\15typescript\1\3\0\0\rprettier\veslint\1\3\0\0\rprettier\veslint\1\0\a\15javascript\0\tjson\0\15typescript\0\bcss\0\thtml\0\rmarkdown\0\vpython\0\1\3\0\0\truff\16ruff_format\15ale_fixers\rmarkdown\1\2\0\0\rmarksman\15javascript\1\2\0\0\veslint\vpython\1\0\3\15javascript\0\rmarkdown\0\vpython\0\1\2\0\0\truff\16ale_linters\6g\bvim\0" },
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/ale",
    url = "https://github.com/dense-analysis/ale"
  },
  ["cellular-automaton.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cellular-automaton.nvim",
    url = "https://github.com/eandrju/cellular-automaton.nvim"
  },
  ["cloak.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cloak.nvim",
    url = "https://github.com/laytan/cloak.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua",
    url = "https://github.com/hrsh7th/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["copilot.vim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/copilot.vim",
    url = "https://github.com/github/copilot.vim"
  },
  ["friendly-snippets"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/friendly-snippets",
    url = "https://github.com/rafamadriz/friendly-snippets"
  },
  harpoon = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/theprimeagen/harpoon"
  },
  ["lsp-zero.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/lsp-zero.nvim",
    url = "https://github.com/VonHeikemen/lsp-zero.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-context"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/nvim-treesitter-context",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-context"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["refactoring.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/refactoring.nvim",
    url = "https://github.com/theprimeagen/refactoring.nvim"
  },
  ["scope.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/scope.nvim",
    url = "https://github.com/tiagovla/scope.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  tokyonight = {
    config = { "\27LJ\2\n@\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0!colorscheme tokyonight-night\bcmd\bvim\0" },
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/tokyonight",
    url = "https://github.com/folke/tokyonight.nvim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\nC\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\nicons\1\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  undotree = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["zen-mode.nvim"] = {
    loaded = true,
    path = "/Users/calwetzel/.local/share/nvim/site/pack/packer/start/zen-mode.nvim",
    url = "https://github.com/folke/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: tokyonight
time([[Config for tokyonight]], true)
try_loadstring("\27LJ\2\n@\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0!colorscheme tokyonight-night\bcmd\bvim\0", "config", "tokyonight")
time([[Config for tokyonight]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\nC\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\nicons\1\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: ale
time([[Config for ale]], true)
try_loadstring("\27LJ\2\n�\5\0\0\3\0 \00096\0\0\0009\0\1\0005\1\4\0005\2\3\0=\2\5\0015\2\6\0=\2\a\0015\2\b\0=\2\t\1=\1\2\0006\0\0\0009\0\1\0005\1\f\0005\2\v\0=\2\5\0015\2\r\0=\2\a\0015\2\14\0=\2\15\0015\2\16\0=\2\17\0015\2\18\0=\2\19\0015\2\20\0=\2\21\0015\2\22\0=\2\t\1=\1\n\0006\0\0\0009\0\1\0)\1\1\0=\1\23\0006\0\0\0009\0\1\0'\1\25\0=\1\24\0006\0\0\0009\0\1\0'\1\27\0=\1\26\0006\0\0\0009\0\1\0)\1\1\0=\1\28\0006\0\0\0009\0\1\0)\1\1\0=\1\29\0006\0\0\0009\0\1\0'\1\31\0=\1\30\0006\0\0\0009\0\1\0)\1\1\0=\1\23\0K\0\1\0\31[%linter%] %s [%severity%]\24ale_echo_msg_format\25ale_linters_explicit\27ale_completion_enabled\b⚠\21ale_sign_warning\b✘\19ale_sign_error\20ale_fix_on_save\1\2\0\0\rprettier\tjson\1\2\0\0\rprettier\thtml\1\2\0\0\rprettier\bcss\1\2\0\0\rprettier\15typescript\1\3\0\0\rprettier\veslint\1\3\0\0\rprettier\veslint\1\0\a\15javascript\0\tjson\0\15typescript\0\bcss\0\thtml\0\rmarkdown\0\vpython\0\1\3\0\0\truff\16ruff_format\15ale_fixers\rmarkdown\1\2\0\0\rmarksman\15javascript\1\2\0\0\veslint\vpython\1\0\3\15javascript\0\rmarkdown\0\vpython\0\1\2\0\0\truff\16ale_linters\6g\bvim\0", "config", "ale")
time([[Config for ale]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
