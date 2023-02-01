local null_ls = require'null-ls'
local flake8_config = { '--max-line-length', '120' }
null_ls.setup{
  sources = {
    null_ls.builtins.code_actions.gitsigns.with{
      diagnostic_config = {
        signs = false,
        update_in_insert = false,
      },
    },
    null_ls.builtins.diagnostics.flake8.with(
      (function ()
        local args = null_ls.builtins.diagnostics.flake8._opts.args
        for index, arg in ipairs(flake8_config) do
          table.insert(args, index, arg)
        end
        return {
          args = args,
        }
      end)()
    ),
    null_ls.builtins.diagnostics.mypy,
  },
}
