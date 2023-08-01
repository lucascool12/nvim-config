local env_conf = require'neovim-env.config'
local M = {}
local path = require'plenary.path'
local profile = path:new(vim.fn.stdpath('data'), "neovim-env")
local config = path:new(vim.fn.stdpath('config'), "lua", "neovim-env", "config.nix")
local nix_pkg = "neovimEnv"
local args = { "install", "add_package" }

function M.setup()
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

M.nix_present = env_conf.nix_present
M.nixos_system = env_conf.nixos_system

return M
