local tree_exec = require'neo-tree.command'.execute
local window_picker = require'window-picker'

local width = 30
local function is_file(node)
  if (node.type ~= "file") and (node.type ~= "directory") then
    return false
  end
  if node == nil then
    vim.notify("No file selected", nil, nil)
    return false
  end
  return true
end
require'neo-tree'.setup{
  source_selector = {
    winbar = false,
    statusline = false,
  },
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "diagnostics",
  },
  event_handlers = {
    {
      event = "neo_tree_window_after_open",
      handler = function(table)
        if table.position == "left" or table.position == "right" then
          vim.api.nvim_win_set_width(table.winid, width)
        end
        vim.cmd('cd .') -- work around for intial open
      end,
    },
    {
      event = "neo_tree_window_before_close",
      handler = function(table)
        if table.position == "left" or table.position == "right" then
          width = vim.api.nvim_win_get_width(table.winid)
        end
      end,
    },
  },
  filesystem = {
    hijack_netrw_behavior = "open_default",
    window = {
      mappings = {
        ['<cr>'] = "open_with_window_picker",
        ['<2-leftmouse>'] = "open_with_window_picker",
        ['S'] = "split_with_window_picker",
        ['s'] = "vsplit_with_window_picker",
        ['y'] = "yank_file_name",
        ['Y'] = "yank_relative_name",
      },
    },
    commands = {
      yank_file_name = function(state)
        local node = state.tree:get_node()
        if not is_file(node) then
          vim.notify("No file selected", nil, nil)
          return
        end
        local name = node.name
        if name == nil then
          vim.notify("No file selected", nil, nil)
          return
        end
        vim.fn.setreg('""', name)
        vim.fn.setreg("1", name)
      end,
      yank_relative_name = function(state)
        local node = state.tree:get_node()
        if not is_file(node) then
          vim.notify("No file selected", nil, nil)
          return
        end
        local path = node.path
        if path == nil then
          vim.notify("No file selected", nil, nil)
          return
        end
        local cwd = vim.loop.cwd()
        if cwd == nil then
          cwd = ""
        end
        local rel_path = string.sub(path, string.len(cwd) + 2, -1)
        vim.fn.setreg('""', rel_path)
        vim.fn.setreg("1", rel_path)
      end,
    },
  },
}
vim.keymap.set('n', '<leader>tt', function()
  tree_exec({
    action = 'focus',
    source = 'filesystem',
    -- position = 'left',
    toggle = true,
    -- dir = '.',
  })
end)
vim.g.neo_tree_remove_legacy_commands = 1
