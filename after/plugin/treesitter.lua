require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "vimdoc", "javascript", "typescript", "c", "lua", "rust", "python"
  , "cpp","php","html","css","json","markdown","matlab"},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- Use treesitter :Inspect command in vim to determine the @name of the syntax element
  vim.cmd('hi! @keyword.cpp guifg=#e8b923'), -- e.g. class, struct
  vim.cmd('hi! @type.qualifier.cpp guifg=#d4af37'), -- e.g. pulic, private
  vim.cmd('hi! @keyword.operator.cpp guifg=#fffa02'), -- e.g. new, delete
  vim.cmd('hi! @variable.cpp guifg=#bde51a'), -- e.g. variable names
  vim.cmd('hi! @variable.parameter.cpp guifg=#bde51a'), -- e.g. function parameters
  vim.cmd('hi! @constant.cpp guifg=#bde51a'), 
  vim.cmd('hi! @type.cpp guifg=#f41e00'), -- name of class or struct
  vim.cmd('hi! @type.builtin.cpp guifg=#b31942'), -- e.g. int, float
  vim.cmd('hi! @comment.cpp guifg=White'), -- comments
  vim.cmd('hi! @property.cpp guifg=#ABEA7C'), 
  vim.cmd('hi! @variable.member.cpp guifg=#bde51a'),
  vim.cmd('hi! @function.call.cpp guifg=#ff8200'),
  vim.cmd('hi! @function.method.call.cpp guifg=#00ff43'),
  vim.cmd('hi! @function.cpp guifg=#ff8200'),
  vim.cmd('hi! @function.method.cpp guifg=#ff8200'),
  vim.cmd('hi! @keyword.conditional.cpp guifg=#c6c4f8'),
  vim.cmd('hi! @keyword.repeat.cpp guifg=#9c97ff'),
  vim.cmd('hi! @keyword.import.cpp guifg=#0090ff'),
  vim.cmd('hi! @operator.cpp guifg=#32cd32'),
  vim.cmd('hi! @punctuation.bracket.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @punctuation.delimiter.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @punctuation.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @punctuation.special.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @punctuation.operator.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @punctuation.separator.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @punctuation.terminator.cpp guifg=#f5f5dc'),
  vim.cmd('hi! @string.cpp guifg=#fadadd'), -- pale pink strings
  vim.cmd('hi! @string.special.cpp guifg=#fadadd'), -- pale pink strings
  vim.cmd('hi! @string.regexp.cpp guifg=#fadadd'), -- pale pink strings
  
  vim.cmd('hi! @number.cpp guifg=#b31942'),


  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
