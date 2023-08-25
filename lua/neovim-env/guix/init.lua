local job = require'plenary.job'
local path = require'plenary.path'
local M = {}

function M.present()
  return vim.fn.executable("guix") == 1
end

local function count_preceding_backslashes(str, index)
  local amount = 0
  while(true) do
    if str:sub(index - amount, index - amount) ~= '\\' then
      break
    end
    amount = amount + 1
    if index - amount < 1 then
      amount = amount - 1
      break
    end
  end
  return amount
end

local escapes = {
  ["\\a"] = "\a",
  ["\\b"] = "\b",
  ["\\f"] = "\f",
  ["\\n"] = "\n",
  ["\\r"] = "\r",
  ["\\t"] = "\t",
  ["\\v"] = "\v",
}

function escape_any(sub_str)
  if sub_str:sub(1, 1) == '\\' then
    return ""
  end
  return nil
end

local function escape_characters(str)
  local new_str = ""
  for i=1,#str - 1 do
    local replace = escapes[str:sub(i, i + 1)] or escape_any(str:sub(i, i + 1))
    if replace then
      new_str = new_str .. replace
    else
      new_str = new_str .. str:sub(i, i)
    end
  end
  new_str = new_str .. str:sub(#str, #str)
  return new_str
end

local function get_quoted(str)
  local begin, end_first = str:find("\"")
  if end_first == nil then
    return ""
  end
  local end_str = end_first
  while(true) do
    _, end_str = str:find("\"", end_str + 1)
    local amount = count_preceding_backslashes(str, end_str - 1)
    if amount % 2 == 0 then
      break
    end
  end
  return str:sub(end_first + 1, end_str - 1)
end

local function get_env_vars_exportp(vars_str, ignore)
  local prev_begin_index, prev_end_index, _, _ = string.find(vars_str, "export ([^=%s]*)")
  local env_vars = {}
  while(true) do
    local begin_index, end_index, _, _ = string.find(vars_str, "export ([^=%s]*)", prev_end_index)
    local var_end
    if prev_end_index then var_end = prev_end_index else var_end = prev_begin_index end
    local var = vars_str:sub(prev_begin_index + 7, var_end)
    if not ignore[var] then
      local data_end
      if begin_index then data_end = begin_index - 1 else data_end = #vars_str end
      local val = escape_characters(get_quoted(vars_str:sub(prev_end_index + 2, data_end)))
      if prev_end_index + 2 > data_end then env_vars[var] = true else env_vars[var] = val end
    end
    prev_end_index = end_index
    prev_begin_index = begin_index
    if end_index == nil then
      break
    end
  end
  return env_vars
end

M.default_sh_env = {
 ["OLDPWD"] = true,
 ["SHLVL"] = true,
 ["PWD"] = true,
}

function M.shell_source_file(file, ignore)
  if ignore == nil then
    ignore = M.default_sh_env
  end
  file = tostring(file)
  local vars_str = ""
      -- code
    job:new{
      command = "/bin/sh",
      args = {"-c", "source " .. file .."; export -p"},
      env = vim.loop.os_environ(),
      enable_handlers = true,
      on_stdout = function(_, data, _)
        vars_str = vars_str .. tostring(data) .. "\n"
      end,
      on_stderr = function(_, data, _)
      end,
      on_exit = function(code, sig)
        if code.code == 0 then
          
        else
          error(code.code)
        end
      end
    }:sync()
    if vars_str == "" then
      return
    end
    local env_vars = get_env_vars_exportp(vars_str, ignore)
    for var, val in pairs(env_vars) do
      vim.env[var] = val
    end
end

function M.setup(profile)
  if type(profile) == "string" then
    profile = path:new(profile)
  end
  vim.env.GUIX_PROFILE = tostring(profile)
  M.shell_source_file(tostring(profile:joinpath("etc", "profile")))
  vim.api.nvim_create_user_command("Guix",
    function (opts)
      vim.defer_fn(function ()
        local env = vim.loop.os_environ()
        env.GUIX_PROFILE = tostring(profile)
        local args = opts.fargs
        table.insert(args, '-p')
        table.insert(args, tostring(profile))
        for key, val in pairs(args) do
          args[key] = vim.fs.normalize(val)
        end
        print(vim.inspect(args))
        job:new{
          command = "guix",
          args = args,
          env = env,
          enable_handlers = true,
          on_stdout = function(_, data, _)
            print(data)
          end,
          on_stderr = function(_, data, _)
            print(data)
          end,
          on_exit = function(code, _)
            if code.code == 0 then
              vim.defer_fn(require'neovim-env'.setup_new_lsps, 0)
              print("here")
            end
          end,
        }:start()
      end, 0)
    end,
    {
      nargs = "+",
    }
  )
end

return M
