local c = require'ui.colors'
local colors = c.stline_colors_from_theme()
local sbg = vim.o.background == "dark" and c.white or c.black
local highlights = {
  IndentBlanklineChar = { fg = sbg }
}

for group, color in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, color)
end

require("indent_blankline").setup {
  -- for example, context is off by default, use this to turn it on
  -- show_current_context = true,
  -- show_current_context_start = true,
}
