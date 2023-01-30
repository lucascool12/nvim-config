-- mostly inspired/stolen from https://github.com/EdenEast/nyx/tree/8a9819e4ea11193434b2366b9f1d65ed3a4661f3/config/.config/nvim
local u = require'ui.feline.util'
local fmt = string.format
local diagnostic = vim.diagnostic
local colors = require'ui.colors'

local gen_highlights = function()
  local c = colors.stline_colors_from_theme()
  local sfg = vim.o.background == "dark" and c.black or c.white
  local sbg = vim.o.background == "dark" and c.white or c.black
  local ct = colors.tabline_colors_from_theme()
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
    FlnWarnErrorBg = { fg = c.err, bg = c.bg }, -- changed
    FlnErrorStatus = { fg = c.err, bg = sbg },
    FlnStatusBg = { fg = sbg, bg = c.bg },

    FlnAlt = { fg = sbg, bg = ct.sel.bg },
    FlnFileInfo = { fg = c.fg, bg = c.alt },
    FlnAltSep = { fg = c.bg, bg = ct.sel.bg },
    FlnGitBranch = { fg = c.yellow, bg = c.bg },
    FlnGitSeperator = { fg = c.bg, bg = c.alt },
    FlnNeoTreeSource= { fg = c.yellow, bg = c.bg },
    -- vi modes
  }
  for k, v in pairs(groups) do
    colors.highlight(k, v)
  end
end

gen_highlights()

local get_diag = function(severity)
  local count = vim.tbl_count(diagnostic.get(0, severity and {severity = severity }))
  return (count > 0) and " " .. count .. " " or ""
end

local function vi_mode_hl()
  return u.vi.colors[vim.fn.mode()] or "FlnViBlack"
end

local function vi_sep_hl()
  return u.vi.sep[vim.fn.mode()] or "FlnBlack"
end

local c = {
  vimode = {
    provider = 'vi_mode',
    hl = vi_mode_hl,
    right_sep = { str = " ", hl = vi_sep_hl }, -- " "
    left_sep = { str = u.icons.block, hl = vi_sep_hl }, -- " "
    icon = '',
  },
  gitbranch = {
    provider = "git_branch",
    icon = "  ",
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
      local neo_tree_sources = {
        filesystem = " filesystem",
        diagnostics = " diagnostics",
        buffers = "﬘ buffers",
        git_status = " git status" ,
      }
      return fmt("%s ", neo_tree_sources[vim.b.neo_tree_source] or "")
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
      return get_diag(diagnostic.severity.ERROR)
    end,
    hl = "FlnError",
    left_sep = { str = "", hl = "FlnWarnErrorBg", always_visible = true }, -- only if no status
    right_sep = { str = "", hl = "FlnWarnError", always_visible = true },
  },
  lsp_warn = {
    provider = function()
      return get_diag(diagnostic.severity.WARN)
    end,
    hl = "FlnWarn",
    right_sep = { str = "", hl = "FlnInfoWarn", always_visible = true },
  },
  lsp_info = {
    provider = function()
      return get_diag(diagnostic.severity.INFO)
    end,
    hl = "FlnInfo",
    right_sep = { str = "", hl = "FlnHintInfo", always_visible = true },
  },
  lsp_hint = {
    provider = function()
      return get_diag(diagnostic.severity.HINT)
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
    -- c.lsp_status,
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
    -- c.lsp_status,
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
