local path = require'plenary.path'
local config_util = require'config-util'

local M = {}

local function split(str, delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( str, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( str, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( str, delimiter, from  )
  end
  table.insert( result, string.sub( str, from  ) )
  return result
end


function M.lsp_cmds()
  local servers_dir = path:new(config_util.plugin_path, "nvim-lspconfig", "lua", "lspconfig", "server_configurations")
  -- local servers_str = vim.fn.system("ls " .. servers_dir)
  -- local servers = {}
  -- for str in string.gmatch(servers_str, "([^%s]+)") do
  --   table.insert(servers, str:sub(1, #str - 4))
  -- end
  local servers = config_util.ls(servers_dir, function (str) return str:sub(1, #str - 4) end)
  local cmd_to_server = {}
  for _, server in pairs(servers) do
    local cmd = require('lspconfig.server_configurations.' .. server).default_config.cmd
    if type(cmd) == 'function' then
      cmd = cmd()
    elseif type(cmd) == "table" then
      cmd = cmd[1]
    end
    if cmd == nil then
      goto continue
    end
    cmd_to_server[cmd] = server
      ::continue::
  end
  return split(vim.inspect(cmd_to_server), "\n")
end


return M
