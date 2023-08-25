local config_util = require'config-util'
local M = {}
local path = require'plenary.path'
local profile = path:new(vim.fn.stdpath('data'), "neovim-env")
local args = { "install", "add_package" }
local providers = require'neovim-env.providers'

function M.mason()
  return providers.get_provider() == nil
end

local lsp_config
local inited = {}

function M.setup_new_lsps()
  local cmd_to_server = require'neovim-env.cmd_to_server'
  for lsp, conf in pairs(lsp_config) do
    if type(lsp) ~= 'string' then
      goto continue
    end
    if conf.cmd ~= nil then
      cmd_to_server[lsp] = conf.cmd
    end
    if conf.always then
      require'lspconfig'[lsp].setup(conf)
      inited[lsp] = true
    end
      ::continue::
  end
  local cmds = config_util.ls(tostring(profile:joinpath("bin")))
  for _, cmd in pairs(cmds) do
    local lsp = cmd_to_server[cmd]
    if inited[lsp] or lsp == nil then
      goto continue
    end
    if lsp_config[lsp] ~= nil then
      require'lspconfig'[lsp].setup(lsp_config[lsp][1])
    else
      require'lspconfig'[lsp].setup(lsp_config[1])
    end
    inited[lsp] = true
      ::continue::
  end
end

function M.setup()
  local provider = providers.get_provider()
  if provider == nil then
    require'mason-lspconfig'.setup()
    return
  end
  provider.setup(profile)
end

function M.lsp_handlers(configs)
  if M.mason() then
    local mason_lsp = {}
    local default_conf
    local confs = {}
    for lsp, conf in pairs(configs) do
      if lsp == 1 then
        default_conf = conf
      else
        confs[lsp] = true
        require'lspconfig'[lsp].setup(conf[1])
      end
    end
    mason_lsp[1] = function (server_name)
      if confs[server_name] then
        return
      end
      require'lspconfig'[server_name].setup(default_conf)
    end
    require'mason-lspconfig'.setup_handlers(mason_lsp)
    return
  end
  lsp_config = configs
  M.setup_new_lsps()
end

return M
