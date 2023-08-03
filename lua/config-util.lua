local M = {}
local path = require'plenary.path'

M.plugin_path = tostring(path:new(require'packer'.config.package_root, "packer", "start"))

--- @param transform? function
--- @param insert_func? function
function M.ls(p, transform, insert_func)
  p = tostring(p)
  local files_str = vim.fn.system("ls " .. p)
  local files = {}
  for str in string.gmatch(files_str, "([^%s]+)") do
    local insert = insert_func or table.insert
    if transform == nil then
      insert(files, str)
    else
      insert(files, transform(str))
    end
  end
  return files
end

return M
