local null_ls = require'null-ls'
null_ls.setup{
  sources = {
    null_ls.builtins.code_actions.gitsigns.with{
      diagnostic_config = {
        signs = false,
        update_in_insert = false,
      },
    },
  },
}
