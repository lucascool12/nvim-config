require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "lua:mason-sources",
  }
})

local function mason_ensure_installed(servers)
  local mason_reg = require'mason-registry'
  for _, server in ipairs(servers) do
    if not mason_reg.is_installed(server) then
      vim.cmd("MasonInstall " .. server)
    end
  end
end

  
local ensure_installed = {'lua-language-server', 'rust-analyzer', 'pyright'}
mason_ensure_installed(ensure_installed)
