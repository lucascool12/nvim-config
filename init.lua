require('plugins')
require'main'
local path = require'plenary.path'
local win32yank_path = path.new("~/.local/bin/win32yank.exe")
win32yank_path:expand()

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
vim.cmd([[
au BufNewFile,BufRead *.idp set filetype=idp
]])

if win32yank_path:exists() then
  vim.cmd([[
  set clipboard+=unnamed
  ]])
end
