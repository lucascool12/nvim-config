require'nightfox'.setup{
  options = {
    transparent = false,
  },
  specs = {
    all = {
      syntax = {
        variable = "cyan",
      },
    },
  },
  groups = {
    all = {
      Pmenu = { bg = "NONE" },
      NormalFloat = { bg = "NONE" },
      NormalNC = { bg = "NONE" },
      WildMenu = { bg = "NONE" },
      EndOfBuffer = { guifg = "bg" },
      ["@namespace"] = { link = "PreProc" },
      ["@keyword.operator"] = { link = "@keyword.return" },
    },
  },
}
require("onedarkpro").setup({
  colors = {
    purple = "require('onedarkpro.helpers').darken('purple', 15, 'onedark')",
  },
  highlights = {
    NeoTreeDirectoryIcon = {
      fg = "${blue}",
    },
    NeoTreeRootName = {
      fg = "${cyan}",
    },
  }
})
vim.opt.pumblend = 19
vim.cmd("colorscheme terafox")
vim.cmd([[set fillchars=eob:\ ]]) -- get rid of tilde at end of buffer
