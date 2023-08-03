require'signature'
local nenv = require'neovim-env'
if not nenv.nix_present() then
  require'config-mason'
end
