require'nvim-treesitter.configs'.setup {
  ensure_installed = {"lua", "python", "rust"},
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  autotag = {
    enable = true,
  },
  -- indent = {
  --   enable = true,
  -- },
}

local parser_mapping = require("nvim-treesitter.parsers").filetype_to_parsername
parser_mapping.xml = "html" -- map the html parser to be used when using xml files

-- -- temp solution to treesitter indentation not turning off
-- vim.cmd([[
-- autocmd FileType python set indentexpr=
-- autocmd FileType python set autoindent
-- autocmd FileType python set smartindent
-- ]])

