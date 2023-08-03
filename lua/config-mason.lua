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
-- require("mason-lspconfig").setup_handlers {
--   -- The first entry (without a key) will be the default handler
--   -- and will be called for each installed server that doesn't have
--   -- a dedicated handler.
--   function (server_name) -- default handler (optional)
--     require("lspconfig")[server_name].setup {
--       on_attach = on_attach,
--       flags = lsp_flags,
--       capabilities = capabilities,
--     }
--   end,
-- }

require("mason").setup({
  PATH = "skip",
  registries = {
    "github:mason-org/mason-registry",
    "lua:mason-sources",
  }
})
