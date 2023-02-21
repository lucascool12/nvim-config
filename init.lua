require('plugins')
require'main'
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])
vim.cmd([[set modelines=0]])
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- vim.cmd([[set clipboard=unnamedplus]])

if vim.fn.has('macunix') then
  vim.cmd([[let g:python3_host_prog = '/usr/bin/python3.11']])
end

vim.cmd([[
syntax on
filetype indent on
]])
