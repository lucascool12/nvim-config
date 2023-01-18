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
    },
  },
}
vim.opt.pumblend = 19
vim.cmd("colorscheme terafox")
