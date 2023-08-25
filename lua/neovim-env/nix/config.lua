local path = require'plenary.path'
local job = require'plenary.job'
local query_str = [[
(attrset_expression
  (binding_set
    (binding
      (attrpath
        (identifier) @packageOverrides
        (#any-of? @packageOverrides "packageOverrides")
      )
      (function_expression
        (with_expression
          (attrset_expression
            (binding_set
              (binding
                (attrpath
                  (identifier) @neovimEnv
                  (#any-of? @neovimEnv "neovimEnv")
                )
                (apply_expression
                  (attrset_expression
                    (binding_set
                      (binding
                        (attrpath
                          (identifier) @paths
                          (#any-of? @paths "paths")
                        )
                        (list_expression
                          [
                            (select_expression)
                            (variable_expression)
                          ]? @package
                        ) @list
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)
]]
local _query

local function get_query()
  if not _query then
    local res, q = pcall(vim.treesitter.query.parse, 'nix', query_str)
    if res then
      _query = q
    else
      return nil
    end
  end
  return _query
end

local M = {}

function M.nix_present()
  return vim.fn.executable("nix") == 1
end

function M.nixos_system()
  return vim.fn.executable("nixos-version") == 1
end

--- @param on_succes? function
function M.install_config(config, profile, package_name, on_succes)
  if type(config) == "string" then
    config = path:new(config)
  end
  if type(profile) == "string" then
    profile = path:new(profile)
  end
  local pkgs = "nixpkgs"
  if M.nixos_system() then
    pkgs = "nixos"
  end
  vim.defer_fn(function ()
    local env = vim.loop.os_environ()
    env.NIXPKGS_CONFIG = tostring(config)
    job:new{
      command = "nix-env",
      args = { "-p", tostring(profile), "-iA", string.format("%s.%s", pkgs, package_name) },
      env = env,
      enable_handlers = true,
      on_stdout = function(error, data, _)
        print(data)
      end,
      on_stderr = function(error, data, _)
        print(data)
      end,
      on_exit = function(code, sig)
        if code.code == 0 then
          if on_succes ~= nil then
            on_succes()
          end
        end
      end,
    }:start()
  end, 0)
end

function M.add_package(buf, pack)
  local parser = vim.treesitter.get_parser(buf, 'nix')
  local tree = parser:parse()

  local first_node = tree[1]:root()

  local nodes = {}
  local list
  local query = get_query()
  if query == nil then
    error("treesitter for nix not installed")
  end
  for pattern, match, metadata in query:iter_matches(first_node, parser:source(), 0 , 16) do
    for id, node in pairs(match) do
      if query.captures[id] == "package" then
        table.insert(nodes, node)
      elseif query.captures[id] == "list" then
        list = node
      end
    end
  end

  local amount_nodes = #nodes
  local last = nodes[amount_nodes]
  local sec_to_last = nodes[amount_nodes - 1] or last
  local l_list_r, l_list_c, list_r, list_c = list:range()
  if last == nil then
    local line = vim.api.nvim_buf_get_lines(buf, list_r, list_r + 1, true)[1]
    local lines
    if l_list_r == list_r then
      lines = { line:sub(1, l_list_c + 1) .. string.format("%s", pack) .. line:sub(l_list_c + 2, #line) }
      vim.api.nvim_buf_set_lines(buf, list_r, list_r + 1, true, lines)
    else
      local s, _ = line:find("]")
      local tab = tonumber(vim.api.nvim_buf_get_option(buf, "tabstop")) or 2
      lines = { line:sub(1, s - 1) .. (" "):rep(tab) .. string.format("%s", pack), line }
      vim.api.nvim_buf_set_lines(buf, list_r, list_r + 1, true, lines)
    end
    return
  end
  local _, l_last_c, last_r, last_c = last:range()
  local _, _, sec_r, sec_c = sec_to_last:range()
  if last_r == sec_r  and last_r == list_r and sec_r == list_r and last ~= sec_to_last then
    local line = vim.api.nvim_buf_get_lines(buf, last_r, last_r + 1, true)[1]
    line = line:sub(1, last_c) .. string.format(" %s ", pack) .. line:sub(list_c, #line)
    vim.api.nvim_buf_set_lines(buf, last_r, last_r + 1, true, { line })
  elseif last_r == sec_r and last_r ~= list_r and last ~= sec_to_last then
    local line = vim.api.nvim_buf_get_lines(buf, last_r, last_r + 1, true)[1]
    line = line:sub(1, last_c) .. string.format(" %s ", pack) .. line:sub(last_c + 1, #line)
    vim.api.nvim_buf_set_lines(buf, last_r, last_r + 1, true, { line })
  elseif last_r == list_r and last_r ~= sec_r then
    local line = vim.api.nvim_buf_get_lines(buf, last_r, last_r + 1, true)[1]
    local lines = {}
    lines[1] = line:sub(1, last_c)
    lines[2] = line:sub(1, l_last_c) .. string.format("%s ", pack) .. line:sub(list_c, #line)
    vim.api.nvim_buf_set_lines(buf, last_r, last_r + 2, true, lines)
  else
    local line = vim.api.nvim_buf_get_lines(buf, last_r, last_r + 1, true)[1]
    line = line:sub(1, l_last_c) .. pack
    vim.api.nvim_buf_set_lines(buf, last_r + 1, last_r + 1, true, { line })
  end
end

return M
