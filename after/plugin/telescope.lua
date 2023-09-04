vim.cmd([[
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>gf <cmd>Telescope git_files<cr>
nnoremap <leader>u  <cmd>Telescope undo<cr>
]])

require("telescope").setup({
  extensions = {
    undo = {
      -- telescope-undo.nvim config, see below
    },
  },
})
require("telescope").load_extension("undo")
