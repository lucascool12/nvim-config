local nix = require'neovim-env.nix'
local guix = require'neovim-env.guix'
local providers = { 'neovim-env.guix', 'neovim-env.nix' }

local M = {}

local cur_provider
function M.get_provider()
  if cur_provider then
    return cur_provider
  end
  for _, prov_req in pairs(providers) do
    local _, provider = pcall(require, prov_req)
    if provider.present() then
      cur_provider = provider
      return provider
    end
  end
  return nil
end

return M
