require('lint').linters_by_ft = {
  -- markdown = {'vale',},
  python = {'flake8',},
}

vim.cmd([[
au BufWritePost * lua require('lint').try_lint()
]])
