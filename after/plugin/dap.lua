local dap_fncs = require'dap-utils'
local daps = dap_fncs.get_daps()

dap_fncs.set_adapters({
  default = {
    type = 'executable',
  },
  debugpy = {
    type = 'executable',
    command = 'debugpy',
  }
}, daps)

dap_fncs.set_conf({
  default = {
    request = 'attach',
    name = 'default config',
  }
}, daps)
