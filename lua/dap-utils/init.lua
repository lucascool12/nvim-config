local M = {}
local nenv = require'neovim-env'
if nenv.nix_present() then
  return
end
local mason_reg = require'mason-registry'
local dap = require'dap'

local function has_value (tab, val)
    for _, value in ipairs(tab) do
    if value == val then
            return true
        end
    end
    return false
end

local lang_maps = {
  ABAP = { "abap" },
  ["Windows Bat"] = { "bat" },
  BibTeX = { "bibtex" },
  Clojure = { "clojure" },
  Coffeescript = { "coffeescript" },
  C = { "c" },
  ["C++"] = { "cpp" },
  ["C#"] = { "csharp" },
  Compose = { "dockercompose" },
  CSS = { "css" },
  ["CUDA C++"] = { "cuda-cpp" },
  Diff = { "diff" },
  Dockerfile = { "dockerfile" },
  ["F#"] = { "fsharp" },
  Git = { "git-commit", "git-rebase" },
  Go = { "go" },
  Groovy = { "groovy" },
  Handlebars = { "handlebars" },
  Haml = { "haml" },
  HTML = { "html" },
  Ini = { "ini" },
  Java = { "java" },
  JavaScript = { "javascript" },
  ["JavaScript JSX"] = { "javascriptreact" },
  JSON = { "json" },
  ["JSON with Comments"] = { "jsonc" },
  LaTeX = { "latex" },
  Less = { "less" },
  Lua = { "lua" },
  Makefile = { "makefile" },
  Markdown = { "markdown" },
  ["Objective-C"] = { "objective-c" },
  ["Objective-C++"] = { "objective-cpp" },
  Perl = { "perl", "perl6" },
  PHP = { "php" },
  ["Plain Text"] = { "plaintext" },
  PowerShell = { "powershell" },
  ["Pug jade"] = { "pug" },
  Python = { "python" },
  R ={ "r" },
  Razor = { "razor" },
  Ruby = { "ruby" },
  Rust = { "rust" },
  SCSS = { "scss", "sass" },
  ShaderLab = { "shaderlab" },
  ["Shell Script (Bash)"] = { "shellscript" },
  Slim = { "slim" },
  SQL = { "sql" },
  Stylus = { "stylus" },
  Swift = { "swift" },
  TypeScript = { "typescript" },
  ["TypeScript JSX"] = { "typescriptreact" },
  TeX = { "tex" },
  ["Visual Basic"] = { "vb" },
  Vue = { "vue" },
  ["Vue HTML"] = { "vue-html" },
  XML = { "xml" },
  XSL = { "xsl" },
  YAML = { "yaml" },
}

function M.get_daps()
  local packages = mason_reg.get_installed_package_names()
  local daps = {}
  for _, value in pairs(packages) do
    local pack = mason_reg.get_package(value)
    if has_value(pack.spec.categories, "DAP") then
      for _, lang in pairs(pack.spec.languages) do
        if not lang_maps[lang] then
          print("No lang map for:" .. lang ..", for dap:" .. pack.spec.name)
          goto continue
        end
        local langs_mapped = lang_maps[lang]
        for _, lang_mapped in pairs(langs_mapped) do
          if not daps[lang_mapped] then
            daps[lang_mapped] = {}
          end
          local pack_list = { pack }
          vim.list_extend(daps[lang_mapped], pack_list)
        end
        ::continue::
      end
    end
  end
  return daps
end

function M.set_adapters(conf, daps)
  if not daps then
    daps = M.get_daps()
  end
  for lang, dap_packs in pairs(daps) do
    for _, dap_pack in pairs(dap_packs) do
      if conf[dap_pack.spec.name] then
        dap.adapters[dap_pack.spec.name] = conf[dap_pack.spec.name]
      else
        local dap_conf = conf.default
        dap_conf.command = dap_pack.spec.bin
        dap.adapters[dap_pack.spec.name] = dap_conf
      end
    end
  end
end

function M.set_conf(conf, daps)
  if not daps then
    daps = M.get_daps()
  end
  for lang, dap_packs in pairs(daps) do
    for _, dap_pack in pairs(dap_packs) do
      if not dap.configurations[lang] then
        dap.configurations[lang] = {}
      end
      if conf[dap_pack.spec.name] then
        vim.list_extend(dap.configurations[lang], { conf[dap_pack.spec.name] })
      else
        local dap_conf = conf.default
        dap_conf.type = dap_pack.spec.name
        vim.list_extend(dap.configurations[lang], { dap_conf })
      end
    end
  end
end

return M
