require('plugins')
-- auto packerCompile on saveing plugins.lua, doesnt work
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])
vim.cmd([[set modelines=0]])
-- nvim.tree:
-- disable netrw at the very start of your init.lua (strongly advised)
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- vim.cmd([[set clipboard=unnamedplus]])

vim.g.neo_tree_remove_legacy_commands = 1
vim.cmd([[let g:python3_host_prog = '/usr/bin/python3.9']])

vim.cmd([[
syntax on
filetype indent on
]])
