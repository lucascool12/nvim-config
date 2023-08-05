-- require'main'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = require'plugins'
require'lazy'.setup(plugins)
local path = require'plenary.path'
local win32yank_path = path.new("~/.local/bin/win32yank.exe")
win32yank_path:expand()

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

vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufRead" },
  {
    pattern = { "*.idp" },
    command = [[set filetype=idp]],
  }
)

if win32yank_path:exists() then
  vim.cmd([[
  set clipboard+=unnamed
  ]])
end

