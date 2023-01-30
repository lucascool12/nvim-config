local c = require'ui.colors'
local colors = c.stline_colors_from_theme()
local bg = colors.bg

local highlight = {
  -- general
  TitleString = { fg = colors.fg },
  TitleIcon = { fg = colors.red },
  SagaBorder = { bg = bg, fg = colors.blue },
  SagaNormal = { bg = bg },
  SagaExpand = { fg = colors.red },
  SagaCollapse = { fg = colors.red },
  SagaBeacon = { bg = colors.magenta },
  -- code action
  ActionPreviewNormal = { link = 'SagaNormal' },
  ActionPreviewBorder = { link = 'SagaBorder' },
  ActionPreviewTitle = { fg = colors.purple, bg = bg },
  CodeActionNormal = { link = 'SagaNormal' },
  CodeActionBorder = { link = 'SagaBorder' },
  CodeActionText = { fg = colors.orange },
  CodeActionNumber = { fg = colors.green },
  -- finder
  FinderSelection = { fg = colors.cyan, bold = true },
  FinderFileName = { fg = colors.white },
  FinderCount = { link = 'Label' },
  FinderIcon = { fg = colors.cyan },
  FinderType = { fg = colors.purple },
  --finder spinner
  FinderSpinnerTitle = { fg = colors.magenta, bold = true },
  FinderSpinner = { fg = colors.magenta, bold = true },
  FinderPreviewSearch = { link = 'Search' },
  FinderVirtText = { fg = colors.red },
  FinderNormal = { link = 'SagaNormal' },
  FinderBorder = { link = 'SagaBorder' },
  FinderPreviewBorder = { link = 'SagaBorder' },
  -- definition
  DefinitionBorder = { link = 'SagaBorder' },
  DefinitionNormal = { link = 'SagaNormal' },
  DefinitionSearch = { link = 'Search' },
  -- hover
  HoverNormal = { link = 'SagaNormal' },
  HoverBorder = { link = 'SagaBorder' },
  -- rename
  RenameBorder = { link = 'SagaBorder' },
  RenameNormal = { fg = colors.orange, bg = bg },
  RenameMatch = { link = 'Search' },
  -- diagnostic
  DiagnosticBorder = { link = 'SagaBorder' },
  DiagnosticSource = { fg = 'gray' },
  DiagnosticNormal = { link = 'SagaNormal' },
  DiagnosticErrorBorder = { link = 'DiagnosticError' },
  DiagnosticWarnBorder = { link = 'DiagnosticWarn' },
  DiagnosticHintBorder = { link = 'DiagnosticHint' },
  DiagnosticInfoBorder = { link = 'DiagnosticInfo' },
  DiagnosticPos = { fg = colors.gray },
  DiagnosticWord = { fg = colors.fg },
  -- Call Hierachry
  CallHierarchyNormal = { link = 'SagaNormal' },
  CallHierarchyBorder = { link = 'SagaBorder' },
  CallHierarchyIcon = { fg = colors.purple },
  CallHierarchyTitle = { fg = colors.red },
  -- lightbulb
  LspSagaLightBulb = { link = 'DiagnosticSignHint' },
  -- shadow
  SagaShadow = { bg = colors.black },
  -- Outline
  OutlineIndent = { fg = colors.magenta },
  OutlinePreviewBorder = { link = 'SagaNormal' },
  OutlinePreviewNormal = { link = 'SagaBorder' },
  -- Float term
  TerminalBorder = { link = 'SagaBorder' },
  TerminalNormal = { link = 'SagaNormal' },
}

for group, color in pairs(highlight) do
  c.highlight(group, color)
end
