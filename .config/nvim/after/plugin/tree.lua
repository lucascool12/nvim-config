local keymap = vim.keymap.set
-- empty setup using defaults
require("nvim-tree").setup()
-- ToggleTree
keymap("n", "<leader>tt", "<cmd>NvimTreeToggle<cr>")
vim.cmd([[
nnoremap <leader>l <cmd>call setqflist([])<cr>
]])
