print("test json")
vim.cmd([[
autocmd InsertEnter *.json setlocal conceallevel=0
autocmd InsertLeave *.json setlocal concealcursor=inc
]])
vim.cmd([[setlocal conceallevel=0]])
