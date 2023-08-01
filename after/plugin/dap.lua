if require'neovim-env'.nix_present() then
  return
end
local dap_fncs = require'dap-utils'
local daps = dap_fncs.get_daps()

dap_fncs.set_adapters({
  default = {
    type = 'executable',
  },
  debugpy = {
    type = 'executable',
    command = 'debugpy-adapter',
  }
}, daps)

dap_fncs.set_conf({
  default = {
    request = 'attach',
    name = 'default config',
  }
}, daps)
