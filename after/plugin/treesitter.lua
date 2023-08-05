local curl = require'plenary.curl'
local path = require'plenary.path'
local config_util = require'config-util'
local query_path = path:new(config_util.plugin_path, "nvim-treesitter/queries/")

require'nvim-treesitter.configs'.setup {
  ensure_installed = {"lua", "python", "rust", "nix"},
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  autotag = {
    enable = true,
  },
  -- indent = {
  --   enable = true,
  -- },
}

local function add_parser(url, name, highlight)
  local parser_config = require'nvim-treesitter.parsers'.get_parser_configs()
  parser_config[name] = {
    install_info = {
      url = url, -- local path or git repo
      files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
    },
  }
  local output_path = query_path:joinpath(name)
  local output_file = output_path:joinpath("highlights.scm")

  if not output_path:exists() or not output_file:exists() then
    if not output_path:exists() then
      output_path:mkdir()
    end
    local highlight_file = curl.get({ url=highlight }).body
    output_file:write(highlight_file, "w")
  else
  end
end

-- add_parser(
--   "https://github.com/lucascool12/tree-sitter-xml.git",
--   "xml",
--   "https://raw.githubusercontent.com/lucascool12/tree-sitter-xml/master/queries/highlights.scm"
-- )

-- add_parser(
--   "https://github.com/lucascool12/tree-sitter-idp.git",
--   "idp",
--   "https://raw.githubusercontent.com/lucascool12/tree-sitter-idp/master/queries/highlights.scm"
-- )
