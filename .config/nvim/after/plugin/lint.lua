local flake8l = require('lint').linters.flake8
local dmypy = require('lint').linters.mypy
require('lint').linters.flake8120 = flake8l
-- require('lint').linters.flake8120.cmd = "flake8 --max-line-length 120"
require('lint').linters.flake8120.stdin = false
require('lint').linters.flake8120.args = {
  '--max-line-length',
  '120',
  '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
  '--no-show-source',
}
dmypy.cmd = "dmypy"
dmypy.args = {
  'run',
  '--',
}

require('lint').linters.dmypy = dmypy
require('lint').linters_by_ft = {
  python = {'flake8120','mypy'}
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
