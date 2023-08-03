local env_conf = require'neovim-env.config'
local config_util = require'config-util'
local M = {}
local path = require'plenary.path'
local profile = path:new(vim.fn.stdpath('data'), "neovim-env")
local config = path:new(vim.fn.stdpath('config'), "lua", "neovim-env", "config.nix")
local nix_pkg = "neovimEnv"
local args = { "install", "add_package" }

M.nix_present = env_conf.nix_present
M.nixos_system = env_conf.nixos_system

function M.setup()
  if not M.nix_present() then
    require'mason-lspconfig'.setup()
    return
  end
  vim.env.PATH = string.format("%s:%s", profile:joinpath("bin"), vim.env.PATH)
  vim.api.nvim_create_user_command("NeovimEnv",
    function (opts)
      if opts.fargs[1] == args[1] then
        env_conf.install_config(config, profile, nix_pkg)
      elseif opts.fargs[1] == args[2] then
        if #opts.fargs < 2 then
          vim.api.nvim_err_writeln("Packages expected")
          return
        end
        local packages, t, l = pairs(opts.fargs)
        local buf
        local already_open = false
        for _, b in pairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_get_name(b) == tostring(config) then
            buf = b
            already_open = true
            break
          end
        end
        buf = buf or vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(buf, tostring(config))
        vim.api.nvim_buf_call(buf, vim.cmd.edit)
        for _, pack in packages, t, 1 do
          env_conf.add_package(buf, pack)
        end
        vim.api.nvim_buf_call(buf, vim.cmd.write)
        if not already_open then
          vim.api.nvim_buf_delete(buf, {})
        end
      end
    end,
    {
      nargs = "+",
      complete = function(argLead, CmdLine, CursorPos)
        return args
      end
    }
  )
end

function M.lsp_handlers(configs)
  if not M.nix_present() then
    local mason_lsp = {}
    for lsp, conf in pairs(configs) do
      if type(lsp) ~= "string" then
        mason_lsp[lsp] = function (server_name)
          require'lspconfig'[server_name].setup(conf)
        end
      else
        mason_lsp[lsp] = function ()
          require'lspconfig'[lsp].setup(conf[1])
        end
      end
    end
    require'mason-lspconfig'.setup_handlers(mason_lsp)
    return
  end
  local cmd_to_server = require'neovim-env.cmd_to_server'
  local inited = {}
  for lsp, conf in pairs(configs) do
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
    if configs[lsp] ~= nil then
      require'lspconfig'[lsp].setup(configs[lsp][1])
    else
      require'lspconfig'[lsp].setup(configs[1])
    end
      ::continue::
  end
end

return M
