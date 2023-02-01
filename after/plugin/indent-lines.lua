local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  return
end

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
vim.g.indentLine_enabled = 0
vim.api.nvim_create_autocmd({"BufWinEnter"},{
  callback = function (ev)
    if vim.api.nvim_buf_get_option(ev.buf, "filetype") == "toggleterm" then
      return
    end
    if vim.api.nvim_buf_get_option(ev.buf, "buftype") == "" then
      vim.cmd("IndentLinesEnable")
    end
  end,
})
