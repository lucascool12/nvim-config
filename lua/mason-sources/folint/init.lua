local Pkg = require'mason-core.package'
local pip = require'mason-core.managers.pip3'

return Pkg.new {
  name = "folint",
  desc = [[A linter for idp]],
  homepage = "https://gitlab.com/krr/IDP-Z3/-/tree/main/folint",
  languages = { "idp z3" },
  categories = { Pkg.Cat.Linter },
  install = pip.packages{ "folint", bin = { "folint" } },
}
