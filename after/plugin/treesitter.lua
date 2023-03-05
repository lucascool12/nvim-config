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

local parser_config = require'nvim-treesitter.parsers'.get_parser_configs()
parser_config.xml = {
  install_info = {
    url = "https://github.com/lucascool12/tree-sitter-xml.git", -- local path or git repo
    files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
  },
}
local parser_mapping = require("nvim-treesitter.parsers").filetype_to_parsername
-- parser_mapping.xml = "html" -- map the html parser to be used when using xml files

-- -- temp solution to treesitter indentation not turning off
-- vim.cmd([[
-- autocmd FileType python set indentexpr=
-- autocmd FileType python set autoindent
-- autocmd FileType python set smartindent
-- ]])

