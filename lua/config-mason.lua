if require'neovim-env'.nix_present() then
  return
end
require("mason").setup({
  PATH = "skip",
  registries = {
    "github:mason-org/mason-registry",
    "lua:mason-sources",
  }
})
