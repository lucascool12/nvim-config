local path = require'plenary.path'
local env_conf = require'neovim-env.nix.config'
local config = path:new(vim.fn.stdpath('config'), "lua", "neovim-env", "nix", "config.nix")
local args = { "install", "add_package" }
local nix_pkg = "neovimEnv"

local M = {}

M.present = env_conf.nix_present

function M.setup(profile)
  vim.env.PATH = string.format("%s:%s", profile:joinpath("bin"), vim.env.PATH)
  if type(profile) == "string" then
    profile = path:new(profile)
  end
  vim.api.nvim_create_user_command("NeovimEnv",
    function (opts)
      if opts.fargs[1] == args[1] then
        env_conf.install_config(config, profile, nix_pkg, function ()
          vim.defer_fn(require'neovim-env'.setup_new_lsps, 0)
        end)
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

return M
