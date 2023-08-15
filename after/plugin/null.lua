if true then
  return {}
end

local null_ls = require'null-ls'
local method = require'null-ls.methods'
local flake8_config = { '--max-line-length', '120' }
local helpers = require'null-ls.helpers'

null_ls.setup{
  sources = {
    null_ls.builtins.code_actions.gitsigns.with{
      diagnostic_config = {
        signs = false,
        update_in_insert = false,
      },
    },
    -- null_ls.builtins.diagnostics.flake8.with(
    --   (function ()
    --     local args = null_ls.builtins.diagnostics.flake8._opts.args
    --     for index, arg in ipairs(flake8_config) do
    --       table.insert(args, index, arg)
    --     end
    --     return {
    --       args = args,
    --     }
    --   end)()
    -- ),
    null_ls.builtins.diagnostics.mypy.with({
      method = method.internal.DIAGNOSTICS_ON_SAVE,
      extra_args = function ()
        if vim.env.VIRTUAL_ENV then
          return {
            "--python-executable", vim.env.VIRTUAL_ENV .. "/bin/python",
          }
        else
          return {}
        end
      end
    }),
  },
}

if vim.fn.executable('folint') == 1 then
  local folint = {
    name = "FOlint",
    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    filetypes = { "idp" },
    generator = helpers.generator_factory{
      args = { "$FILENAME" },
      command = "folint",
      format = "line",
      on_output = helpers.diagnostics.from_pattern(
        [[((%u)%w+): line (%d+) -- colStart (%d+) -- colEnd (%d+) => (.*)]],
        {"code", "severity", "row", "col", "col_end", "message"}
      )
    },
  }
  null_ls.register(folint)
end
