-- lazygit
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  id = 10,
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "double",
  },
  hidden = true, -- ctrl + \ cannot be used to open lazygit term
  on_create = function (term)
    -- escape acts like escape in lazygit
	  vim.cmd("tnoremap <buffer> <Esc> <Esc>")
    -- ctrl + \ get out of lazygit
    vim.cmd("tnoremap <buffer> <c-\\> <cmd>" .. tostring(term.id) .. "ToggleTerm<CR>")
  end,
  -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  -- function to run on closing the terminal
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _lazygit_toggle()
  lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
