-- from https://github.com/seblj/dotfiles/blob/master/nvim/lua/config/lspconfig/signature.lua
local M = {}
local create_augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local handler
local clients = {}
local api = vim.api
local util = vim.lsp.util
local validate = vim.validate
local npcall = vim.F.npcall

-- straight from neovim runtime vim.lsp.util 
-- events changed
function M.signature_help(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method
  if api.nvim_get_current_buf() ~= ctx.bufnr then
    -- Ignore result since buffer changed. This happens for slow language servers.
    return
  end
  -- When use `autocmd CompleteDone <silent><buffer> lua vim.lsp.buf.signature_help()` to call signatureHelp handler
  -- If the completion item doesn't have signatures It will make noise. Change to use `print` that can use `<silent>` to ignore
  if not (result and result.signatures and result.signatures[1]) then
    if config.silent ~= true then
      print('No signature help available')
    end
    return
  end
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local triggers =
    vim.tbl_get(client.server_capabilities, 'signatureHelpProvider', 'triggerCharacters')
  local ft = api.nvim_buf_get_option(ctx.bufnr, 'filetype')
  local lines, hl = util.convert_signature_help_to_markdown_lines(result, ft, triggers)
  lines = util.trim_empty_lines(lines)
  if vim.tbl_isempty(lines) then
    if config.silent ~= true then
      print('No signature help available')
    end
    return
  end
  local fbuf, fwin = M.open_floating_preview(lines, 'markdown', config)
  if hl then
    api.nvim_buf_add_highlight(fbuf, -1, 'LspSignatureActiveParameter', 0, unpack(hl))
  end
  return fbuf, fwin
end

local function find_window_by_var(name, value)
  for _, win in ipairs(api.nvim_list_wins()) do
    if npcall(api.nvim_win_get_var, win, name) == value then
      return win
    end
  end
end

local function close_preview_window(winnr, bufnrs)
  vim.schedule(function()
    -- exit if we are in one of ignored buffers
    if bufnrs and vim.tbl_contains(bufnrs, api.nvim_get_current_buf()) then
      return
    end

    local augroup = 'preview_window_' .. winnr
    pcall(api.nvim_del_augroup_by_name, augroup)
    pcall(api.nvim_win_close, winnr, true)
  end)
end

local function close_preview_autocmd(events, winnr, bufnrs)
  local augroup = api.nvim_create_augroup('preview_window_' .. winnr, {
    clear = true,
  })

  -- close the preview window when entered a buffer that is not
  -- the floating window buffer or the buffer that spawned it
  api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function()
      close_preview_window(winnr, bufnrs)
    end,
  })

  for event, fnc in pairs(events) do
    api.nvim_create_autocmd(event, {
      group = augroup,
      buffer = bufnrs[2],
      callback = function()
        if fnc(winnr, bufnrs) then
          close_preview_window(winnr)
        end
      end,
    })
  end
end

function M.open_floating_preview(contents, syntax, opts)
  validate({
    contents = { contents, 't' },
    syntax = { syntax, 's', true },
    opts = { opts, 't', true },
  })
  opts = opts or {}
  opts.wrap = opts.wrap ~= false -- wrapping by default
  opts.stylize_markdown = opts.stylize_markdown ~= false and vim.g.syntax_on ~= nil
  opts.focus = opts.focus ~= false
  local always = function () return true end
  opts.close_events = opts.close_events or {
    ['CursorMoved'] = always,
    ['CursorMovedI'] = always,
    ['InsertCharPre'] = always
  }

  local bufnr = api.nvim_get_current_buf()

  -- check if this popup is focusable and we need to focus
  if opts.focus_id and opts.focusable ~= false and opts.focus then
    -- Go back to previous window if we are in a focusable one
    local current_winnr = api.nvim_get_current_win()
    if npcall(api.nvim_win_get_var, current_winnr, opts.focus_id) then
      api.nvim_command('wincmd p')
      return bufnr, current_winnr
    end
    do
      local win = find_window_by_var(opts.focus_id, bufnr)
      if win and api.nvim_win_is_valid(win) and vim.fn.pumvisible() == 0 then
        -- focus and return the existing buf, win
        api.nvim_set_current_win(win)
        api.nvim_command('stopinsert')
        return api.nvim_win_get_buf(win), win
      end
    end
  end

  -- check if another floating preview already exists for this buffer
  -- and close it if needed
  local existing_float = npcall(api.nvim_buf_get_var, bufnr, 'lsp_floating_preview')
  if existing_float and api.nvim_win_is_valid(existing_float) then
    api.nvim_win_close(existing_float, true)
  end

  local floating_bufnr = api.nvim_create_buf(false, true)
  local do_stylize = syntax == 'markdown' and opts.stylize_markdown

  -- Clean up input: trim empty lines from the end, pad
  contents = util._trim(contents, opts)

  if do_stylize then
    -- applies the syntax and sets the lines to the buffer
    contents = util.stylize_markdown(floating_bufnr, contents, opts)
  else
    if syntax then
      api.nvim_buf_set_option(floating_bufnr, 'syntax', syntax)
    end
    api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
  end

  -- Compute size of float needed to show (wrapped) lines
  if opts.wrap then
    opts.wrap_at = opts.wrap_at or api.nvim_win_get_width(0)
  else
    opts.wrap_at = nil
  end
  local width, height = util._make_floating_popup_size(contents, opts)

  local float_option = util.make_floating_popup_options(width, height, opts)
  local floating_winnr = api.nvim_open_win(floating_bufnr, false, float_option)
  if do_stylize then
    api.nvim_win_set_option(floating_winnr, 'conceallevel', 2)
    api.nvim_win_set_option(floating_winnr, 'concealcursor', 'n')
  end
  -- disable folding
  api.nvim_win_set_option(floating_winnr, 'foldenable', false)
  -- soft wrapping
  api.nvim_win_set_option(floating_winnr, 'wrap', opts.wrap)

  api.nvim_buf_set_option(floating_bufnr, 'modifiable', false)
  api.nvim_buf_set_option(floating_bufnr, 'bufhidden', 'wipe')
  api.nvim_buf_set_keymap(
    floating_bufnr,
    'n',
    'q',
    '<cmd>bdelete<cr>',
    { silent = true, noremap = true, nowait = true }
  )
  close_preview_autocmd(opts.close_events, floating_winnr, { floating_bufnr, bufnr })

  -- save focus_id
  if opts.focus_id then
    api.nvim_win_set_var(floating_winnr, opts.focus_id, bufnr)
  end
  api.nvim_buf_set_var(bufnr, 'lsp_floating_preview', floating_winnr)

  return floating_bufnr, floating_winnr
end

local check_trigger_char = function(line_to_cursor, triggers)
  if not triggers then
    return false
  end

  for _, trigger_char in ipairs(triggers) do
    local current_char = line_to_cursor:sub(#line_to_cursor, #line_to_cursor)
    local prev_char = line_to_cursor:sub(#line_to_cursor - 1, #line_to_cursor - 1)
    if current_char == trigger_char then
      return true
    end
    if current_char == ' ' and prev_char == trigger_char then
      return true
    end
  end
  return false
end

local open_signature = function()
  local triggered = false

  for _, client in pairs(clients) do
    local triggers = client.server_capabilities.signatureHelpProvider.triggerCharacters
    -- print(triggers)
    -- for key, value in pairs(triggers) do
    --   print(tostring(key) .. "  " .. tostring(value))
    -- end

    -- csharp has wrong trigger chars for some odd reason
    if client.name == 'csharp' then
      triggers = { '(', ',' }
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local line_to_cursor = line:sub(1, pos[2])

    if not triggered then
      triggered = check_trigger_char(line_to_cursor, triggers)
    end
  end

  if triggered then
    local params = util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, handler)
  end
end

local amount_open_brackets = 0
local function insertClose()
  local char = vim.v.char
  if char == '(' then
    amount_open_brackets = amount_open_brackets + 1
    return false
  elseif char == ')' then
    if amount_open_brackets == 0 then
      amount_open_brackets = 0
      return true
    end
    amount_open_brackets = amount_open_brackets - 1
  end
  return false
end

local start_pos = { 0, 0}
local function move_to_high()
  local pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] <= start_pos[1] and pos[2] < start_pos[2] then
    return true
  end
  return false
end

local cur_win = -1
local cur_buf = -1

vim.keymap.set('i', '<C-e>',
function ()
  if type(cur_win) == "number" and vim.api.nvim_win_is_valid(cur_win) then
    close_preview_window(cur_win, { cur_buf, vim.api.nvim_get_current_win() })
    -- vim.keymap.del('i', '<C-e>')
  end
end)

M.setup = function(client)
  if client.server_capabilities.signatureHelpProvider == nil then
    return
  end
  local handler_butt = vim.lsp.with(M.signature_help, {
    border = "rounded",
    silent = true,
    focusable = false,
    relative ='editor',
    close_events = {
      ['InsertCharPre'] = insertClose,
      ['CursorMovedI'] = move_to_high,
      ['ModeChanged'] = function() return true end,
    },
  })
  handler = function(err, res, ctx, conf)
    -- TODO
    -- different start trigger chars than (
    start_pos = vim.api.nvim_win_get_cursor(0)
    local fbuf, fwin = handler_butt(err, res, ctx, conf)
    cur_buf = fbuf
    cur_win = fwin
  end
  table.insert(clients, client)
  vim.keymap.set({ 'i', 'n' }, '<C-s>', function ()
    local params = util.make_position_params()
    local sole_sig_handler = vim.lsp.with(M.signature_help, {
      border = "rounded",
      silent = true,
      focusable = false,
      relative ='editor',
    })
    vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, sole_sig_handler)
  end)

  local group = create_augroup('LspSignature', { clear = false })
  vim.api.nvim_clear_autocmds({ group = group, pattern = '<buffer>' })
  autocmd('TextChangedI', {
    group = group,
    pattern = '<buffer>',
    callback = function()
      -- Guard against spamming of method not supported after
      -- stopping a language serer with LspStop
      local active_clients = vim.lsp.get_active_clients()
      if #active_clients < 1 then
        return
      end
      open_signature()
    end,
    desc = 'Start lsp signature',
  })
end

return M
