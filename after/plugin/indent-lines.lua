local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/indentLine'
if fn.empty(fn.glob(install_path)) > 0 then
  return
end

function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
vim.g.indentLine_enabled = 0
vim.api.nvim_create_autocmd({"BufWinEnter"},{
  callback = function (ev)
    if contains({"toggleterm"}, vim.api.nvim_buf_get_option(ev.buf, "filetype")) then
      return
    end
    if vim.api.nvim_buf_get_option(ev.buf, "buftype") == "" then
      vim.cmd("IndentLinesEnable")
    end
  end,
})
