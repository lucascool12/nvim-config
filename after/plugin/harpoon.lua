local marks = require'harpoon.mark'
local ui = require'harpoon.ui'

require'harpoon'.setup{
  save_on_toggle = true,
}

require'telescope'.load_extension('harpoon')
vim.keymap.set('n', '<leader>th', '<cmd>Telescope harpoon marks<cr>')
vim.keymap.set('n', '<leader>ha', marks.add_file)
vim.keymap.set('n', '<leader>hr', marks.rm_file)
vim.keymap.set('n', '<leader>hc', marks.clear_all)
vim.keymap.set('n', '<leader>hh', ui.toggle_quick_menu)
vim.keymap.set('n', '<A-.>', ui.nav_next)
vim.keymap.set('n', '<A-,>', ui.nav_prev)
vim.keymap.set('n', 'gh', function ()
  local index = vim.v.count
  if index <= 0 then index = 1 end
  ui.nav_file(index)
end)
