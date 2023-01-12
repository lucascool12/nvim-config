-- ctrl+z and ctrl+y - undo redo, esc to exit terminal mode
vim.cmd("tnoremap <Esc> <C-\\><C-n>")
vim.cmd([[
nnoremap <C-Z> u
nnoremap <C-Y> <C-R>
inoremap <C-Z> <C-O>u
inoremap <C-Y> <C-O><C-R>
]])
vim.keymap.set({"n", "i"}, "<C-s>", vim.lsp.buf.signature_help)
