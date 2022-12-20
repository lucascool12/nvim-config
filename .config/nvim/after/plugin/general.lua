-- Tabs settings
vim.opt.tabstop = 4 -- size of a hard tabstop (ts).
vim.opt.shiftwidth = 4 -- size of an indentation (sw).
vim.opt.expandtab = true -- always uses spaces instead of tab characters (et).
vim.opt.softtabstop = 4 -- number of spaces a <Tab> counts for. When 0, feature is off (sts).
vim.opt.expandtab = true
-- 2 tab size in lua
vim.cmd([[
autocmd FileType lua setlocal ts=2 sts=2 sw=2
]])

-- No back and forth
vim.cmd("set signcolumn=yes")

-- better line numbers
vim.cmd([[set number]])
vim.cmd([[
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
]])

-- exit with right click menu
vim.cmd([[unmenu PopUp.How-to\ disable\ mouse]])
vim.cmd([[amenu PopUp.Exit :q<CR>]])
