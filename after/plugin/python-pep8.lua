local config_util = require'config-util'
local path = require'plenary.path'
local pep8_path = tostring(path:new(config_util.plugin_path, 'vim-python-pep8-indent/indent'))
vim.cmd([[set indentexpr=]])
vim.b.did_indent = nil
vim.cmd('source '..pep8_path..'/python.vim')
