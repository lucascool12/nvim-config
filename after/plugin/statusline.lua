local u = require'lua.ui.feline.util'
local fmt = string.format

local M = {}

local function highlight(group, color)
  local style = color.style and "gui=" .. color.style or "gui=NONE"
  local fg = color.fg and "guifg=" .. color.fg or "guifg=NONE"
  local bg = color.bg and "guibg=" .. color.bg or "guibg=NONE"
  local sp = color.sp and "guisp=" .. color.sp or ""
  local hl = "highlight " .. group .. " " .. style .. " " .. fg .. " " .. bg .. " " .. sp
  vim.cmd(hl)

  if color.link then
    vim.cmd("highlight! link " .. group .. " " .. color.link)
  end
end

local function fromhl(hl)
  local result = {}
  local list = vim.api.nvim_get_hl_by_name(hl, true)
  for k, v in pairs(list) do
    local name = k == "background" and "bg" or "fg"
    result[name] = string.format("#%06x", v)
  end
  return result
end

local function term(num, default)
  local key = "terminal_color_" .. num
  return vim.g[key] and vim.g[key] or default
end

local function colors_from_theme()
  return {
    bg = fromhl("StatusLine").bg, -- or "#2E3440",
    alt = fromhl("CursorLine").bg, -- or "#475062",
    fg = fromhl("StatusLine").fg, -- or "#8FBCBB",
    hint = fromhl("DiagnosticHint").bg or "#5E81AC",
    info = fromhl("DiagnosticInfo").bg or "#81A1C1",
    warn = fromhl("DiagnosticWarn").bg or "#EBCB8B",
    err = fromhl("DiagnosticError").bg or "#EC5F67",
    black = term(0, "#434C5E"),
    red = term(1, "#EC5F67"),
    green = term(2, "#8FBCBB"),
    yellow = term(3, "#EBCB8B"),
    blue = term(4, "#5E81AC"),
    magenta = term(5, "#B48EAD"),
    cyan = term(6, "#88C0D0"),
    white = term(7, "#ECEFF4"),
  }
end

local function tabline_colors_from_theme()
  return {
    tabl = fromhl("TabLine"),
    norm = fromhl("Normal"),
    sel = fromhl("TabLineSel"),
    fill = fromhl("TabLineFill"),
  }
end

M.gen_highlights = function()
  local c = colors_from_theme()
  local sfg = vim.o.background == "dark" and c.black or c.white
  local sbg = vim.o.background == "dark" and c.white or c.black
  local ct = tabline_colors_from_theme()
  M.colors = c
  local groups = {
    FlnViBlack = { fg = c.white, bg = c.black, style = "bold" },
    FlnViRed = { fg = c.bg, bg = c.red, style = "bold" },
    FlnViGreen = { fg = c.bg, bg = c.green, style = "bold" },
    FlnViYellow = { fg = c.bg, bg = c.yellow, style = "bold" },
    FlnViBlue = { fg = c.bg, bg = c.blue, style = "bold" },
    FlnViMagenta = { fg = c.bg, bg = c.magenta, style = "bold" },
    FlnViCyan = { fg = c.bg, bg = c.cyan, style = "bold" },
    FlnViWhite = { fg = c.bg, bg = c.white, style = "bold" },

    FlnBlack = { fg = c.black, bg = c.white, style = "bold" },
    FlnRed = { fg = c.red, bg = c.bg, style = "bold" },
    FlnGreen = { fg = c.green, bg = c.bg, style = "bold" },
    FlnYellow = { fg = c.yellow, bg = c.bg, style = "bold" },
    FlnBlue = { fg = c.blue, bg = c.bg, style = "bold" },
    FlnMagenta = { fg = c.magenta, bg = c.bg, style = "bold" },
    FlnCyan = { fg = c.cyan, bg = c.bg, style = "bold" },
    FlnWhite = { fg = c.white, bg = c.bg, style = "bold" },

    -- Diagnostics
    FlnHint = { fg = c.black, bg = c.hint, style = "bold" },
    FlnInfo = { fg = c.black, bg = c.info, style = "bold" },
    FlnWarn = { fg = c.black, bg = c.warn, style = "bold" },
    FlnError = { fg = c.black, bg = c.err, style = "bold" },
    FlnStatus = { fg = sfg, bg = sbg, style = "bold" },

    -- Dianostic Seperators
    FlnBgHint = { fg = ct.sel.bg, bg = c.hint },
    FlnHintInfo = { fg = c.hint, bg = c.info },
    FlnInfoWarn = { fg = c.info, bg = c.warn },
    FlnWarnError = { fg = c.warn, bg = c.err },
    FlnErrorStatus = { fg = c.err, bg = sbg },
    FlnStatusBg = { fg = sbg, bg = c.bg },

    FlnAlt = { fg = sbg, bg = ct.sel.bg },
    FlnFileInfo = { fg = c.fg, bg = c.alt },
    FlnAltSep = { fg = c.bg, bg = ct.sel.bg },
    FlnGitBranch = { fg = c.yellow, bg = c.bg },
    FlnGitSeperator = { fg = c.bg, bg = c.alt },
    FlnNeoTreeSource= { fg = c.yellow, bg = c.bg },
  }
  for k, v in pairs(groups) do
    highlight(k, v)
  end
end

M.gen_highlights()

local get_diag = function(str)
  if vim.lsp.diagnostic.get_count == nil then
    return ""
  end
  local count = vim.lsp.diagnostic.get_count(0, str)
  return (count > 0) and " " .. count .. " " or ""
end

local c = {
  vimode = {
    provider = function()
      return string.format(" %s ", u.vi.text[vim.fn.mode()])
    end,
    hl = vi_mode_hl,
    right_sep = { str = " ", hl = vi_sep_hl },
  },
  gitbranch = {
    provider = "git_branch",
    icon = " ",
    hl = "FlnGitBranch",
    right_sep = { str = "  ", hl = "FlnGitBranch" },
    enabled = function()
      return vim.b.gitsigns_status_dict ~= nil
    end,
  },
  file_type = {
    provider = function()
      return fmt(" %s ", vim.bo.filetype:upper())
    end,
    hl = "FlnAlt",
  },
  neo_tree_source = {
    provider = function ()
      return fmt("%s ", vim.b.neo_tree_source)
    end,
    hl = "FlnNeoTreeSource",
    right_sep = { str = "  ", hl = "FlnNeoTreeSource" },
  },
  tree_name = {
    provider = function()
      return fmt("פּ %s ", vim.bo.filetype)
    end,
    hl = "FlnAlt",
    left_sep = { str = " ", hl = "FlnAltSep" },
    right_sep = { str = "", hl = "FlnAltSep" },
  },
  fileinfo = {
    provider = { name = "file_info", opts = { type = "relative" } },
    hl = "FlnAlt",
    left_sep = { str = " ", hl = "FlnAltSep" },
    right_sep = { str = "", hl = "FlnAltSep" },
  },
  file_enc = {
    provider = function()
      local os = u.icons[vim.bo.fileformat] or ""
      return fmt(" %s %s ", os, vim.bo.fileencoding)
    end,
    hl = "StatusLine",
    left_sep = { str = u.icons.left_filled, hl = "FlnAltSep" },
  },
  cur_position = {
    provider = function()
      -- TODO: What about 4+ diget line numbers?
      return fmt(" %3d:%-2d ", unpack(vim.api.nvim_win_get_cursor(0)))
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left_filled, hl = vi_sep_hl },
  },
  cur_percent = {
    provider = function()
      return " " .. require("feline.providers.cursor").line_percentage() .. "  "
    end,
    -- hl = vi_mode_hl,
    left_sep = { str = u.icons.left, hl = vi_mode_hl },
  },
  default = { -- needed to pass the parent StatusLine hl group to right hand side
    provider = "",
    hl = "StatusLine",
  },
  lsp_status = {
    provider = function()
      return require("lsp-status").status()
    end,
    hl = "FlnStatus",
    left_sep = { str = "", hl = "FlnStatusBg", always_visible = true },
    right_sep = { str = "", hl = "FlnErrorStatus", always_visible = true },
  },
  lsp_error = {
    provider = function()
      return get_diag("Error")
    end,
    hl = "FlnError",
    right_sep = { str = "", hl = "FlnWarnError", always_visible = true },
  },
  lsp_warn = {
    provider = function()
      return get_diag("Warning")
    end,
    hl = "FlnWarn",
    right_sep = { str = "", hl = "FlnInfoWarn", always_visible = true },
  },
  lsp_info = {
    provider = function()
      return get_diag("Information")
    end,
    hl = "FlnInfo",
    right_sep = { str = "", hl = "FlnHintInfo", always_visible = true },
  },
  lsp_hint = {
    provider = function()
      return get_diag("Hint")
    end,
    hl = "FlnHint",
    right_sep = { str = "", hl = "FlnBgHint", always_visible = true },
  },

  in_fileinfo = {
    provider = "file_info",
    hl = "StatusLine",
  },
  in_position = {
    provider = "position",
    hl = "StatusLine",
  },
}

local active = {
  { -- left
    c.vimode,
    c.gitbranch,
    c.fileinfo,
    c.default, -- must be last
  },
  { -- right
    c.lsp_status,
    c.lsp_error,
    c.lsp_warn,
    c.lsp_info,
    c.lsp_hint,
    c.file_type,
    c.file_enc,
    c.cur_position,
    c.cur_percent,
  },
}

local active_tree = {
  { -- left
    c.vimode,
    c.neo_tree_source,
    c.tree_name,
    c.default, -- must be last
  },
  { -- right
    c.lsp_status,
    c.lsp_error,
    c.lsp_warn,
    c.lsp_info,
    c.lsp_hint,
    c.file_enc,
    c.cur_position,
    c.cur_percent,
  },
}

local inactive = {
  { c.in_fileinfo }, -- left
  { c.in_position }, -- right
}

require'feline'.setup{
  components = { active = active, inactive = inactive },
  conditional_components = {
    {
      condition = function ()
        return vim.api.nvim_buf_get_option(0, "filetype") == "neo-tree"
      end,
      active = active_tree,
      inactive = inactive,
    },
  },
   force_inactive = {
    filetypes = {
      "neo-tree",
      "packer",
      "dap-repl",
      "dapui_scopes",
      "dapui_stacks",
      "dapui_watches",
      "dapui_repl",
      "LspTrouble",
      "qf",
      "help",
    },
    buftypes = { "terminal" },
    bufnames = {},
  }
}
vim.cmd([[
set laststatus=3
]])
