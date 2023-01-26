-- lazygit
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit_config = {
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
}

local lazygit_yadm_config = {}
for k, v in pairs(lazygit_config) do
  lazygit_yadm_config[k] = v
end
lazygit_yadm_config.cmd = "lazygit --git-dir=$HOME/.config/yadm/repo.git --work-tree=$HOME"
lazygit_yadm_config.dir = nil

local lazygit = Terminal:new(lazygit_config)
local lazygit_yadm = Terminal:new(lazygit_yadm_config)

function Lazygit_toggle()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  if ((vim.v.shell_error ~= 0) and vim.loop.cwd():find(vim.fs.normalize('~/.'), 1, true) == 1)
    or (vim.loop.cwd() == vim.fs.normalize('~/'):sub(1, -2)) then
    lazygit_yadm:toggle()
  else
    lazygit:toggle()
  end
end

vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua Lazygit_toggle()<CR>", {noremap = true, silent = true})
