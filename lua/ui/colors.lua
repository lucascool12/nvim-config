local M = {}

function M.highlight(group, color)
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
  local bg = list["background"] or list["bg"]
  local fg = list["foreground"] or list["fg"]
  result["bg"] = bg ~= nil and string.format("#%06x", list["background"] or list["bg"]) or nil
  result["fg"] = fg ~= nil and string.format("#%06x", list["foreground"] or list["fg"]) or nil

  return result
end
M.fromhl = fromhl

local function term(num, default)
  local key = "terminal_color_" .. num
  return vim.g[key] and vim.g[key] or default
end
M.term = term

M.stline_colors_from_theme = function ()
  return {
    bg = fromhl("StatusLine").bg or "#2E3440",
    alt = fromhl("CursorLine").bg or "#475062",
    fg = fromhl("StatusLine").fg  or "#8FBCBB",
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

M.tabline_colors_from_theme = function ()
  return {
    tabl = fromhl("TabLine"),
    norm = fromhl("Normal"),
    sel = fromhl("TabLineSel"),
    fill = fromhl("TabLineFill"),
  }
end

M.ViModeHl = "ViModeHl"
M.ViModeSepHl = "ViModeSepHl"

return M
