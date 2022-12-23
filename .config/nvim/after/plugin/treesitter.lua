require'nvim-treesitter.configs'.setup {
  ensure_installed = {"lua", "python", "rust"},

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  -- indent = {
  --   enable = true,
  -- },
}

-- -- temp solution to treesitter indentation not turning off
-- vim.cmd([[
-- autocmd FileType python set indentexpr=
-- autocmd FileType python set autoindent
-- autocmd FileType python set smartindent
-- ]])

