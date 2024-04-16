require'neodev'.setup()
local nenv = require'neovim-env'

local keymap = vim.keymap.set
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local configs = require('lspconfig/configs')
local util = require('lspconfig/util')
local lspconfig = require'lspconfig'
local path = util.path

local function lsp_keymap_attach (client, bufnr)
	keymap("n", "<C-f>", vim.lsp.buf.references, { silent = true })
  keymap("n", "K", vim.lsp.buf.hover, { silent = true })
	keymap({"n","v"}, "<leader>ca", vim.lsp.buf.code_action, { silent = true })

	keymap("n", "<C-LeftMouse>", vim.lsp.buf.definition, { silent = true })
	keymap("n", "gD", vim.lsp.buf.definition, { silent = true })

	keymap("n", "<leader>lr", vim.lsp.buf.rename)
end

local on_attach = function(client, bufnr)
  lsp_keymap_attach(client, bufnr)
  require'signature'.setup(client)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require'neovim-env'.setup()

local default = true
local features = {}

local rust_an_config = {
  flags = lsp_flags,
  capabilities = capabilities,
  -- Server-specific settings...
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        noDefaultFeatures = not default,
        features = features,
      }
    }
  }
}

local rust_on_attach = function (client, bufnr)
  on_attach(client, bufnr)
  vim.api.nvim_create_user_command("RustAnalyzer", function (opts)
    local stringtoboolean = { ["true"]=true, ["false"]=false }
    if opts.fargs[1] == "default" then
      local val = stringtoboolean[opts.fargs[2]]
      if val ~= nil then
        default = val
      else
        vim.api.nvim_err_write("Wrong Value!")
        return
      end
    elseif opts.fargs[1] == "features" then
      for id, feature in ipairs(opts.fargs) do
        if id < 2 then
          goto continue
        end
        table.insert(features, feature)
        ::continue::
      end
    end
    local config = vim.tbl_extend("force", rust_an_config, {
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            noDefaultFeatures = not default,
            features = features,
          }
        }
      }
    })
    require'lspconfig'["rust_analyzer"].setup(config)
  end, {
    nargs = "+",
    complete = function(_, CmdLine, _)
      local count = 0
      local is_default = false
      for val in string.gmatch(CmdLine, "([^%s]+)") do
        count = count + 1
        if count > 1 and not is_default then
          if val == "default" then
            is_default = true
          else
            return {}
          end
        end
      end
      if is_default and count == 2 then
        return {"true", "false"}
      end
      return {"default", "features"}
    end,
  })
end

rust_an_config.on_attach = rust_on_attach

nenv.lsp_handlers{
  {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  },
  ['pylsp'] = {
    {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      -- Server-specific settings...
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              maxLineLength = 120,
            }
          }
        }
      }
    },
  },
  ['pyright'] = {
    {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      settings = vim.tbl_deep_extend("force",require'lspconfig.server_configurations.pyright'.default_config.settings, {
        python = {
          analysis = {
            autoImportCompletions = false,
            -- typeCheckingMode = "strict",
          }
        }
      })
    },
  },
  ['lua_ls'] = {
    {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = lsp_flags,
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'},
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = table.insert(vim.api.nvim_get_runtime_file("", true),
            { vim.fs.normalize(vim.fn.stdpath("config") .. "/lua")}),
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        },
      },
    },
  },
  ['rust_analyzer'] = {
    rust_an_config,
  },
  ['turtle_ls'] = {
    {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
    },
    always = true,
  },
}

-- lspconfig['pylsp'].setup{
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
--   -- Server-specific settings...
--   settings = {
--     pylsp = {
--       plugins = {
--         pycodestyle = {
--           maxLineLength = 120,
--         }
--       }
--     }
--   }
-- }
--
-- lspconfig['pyright'].setup{
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
--   settings = vim.tbl_deep_extend("force",require'lspconfig.server_configurations.pyright'.default_config.settings, {
--     python = {
--       analysis = {
--         autoImportCompletions = false,
--         -- typeCheckingMode = "strict",
--       }
--     }
--   })
-- }
--
-- lspconfig['lua_ls'].setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   flags = lsp_flags,
--   settings = {
--     Lua = {
--       runtime = {
--         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--         version = 'LuaJIT',
--       },
--       diagnostics = {
--         -- Get the language server to recognize the `vim` global
--         globals = {'vim'},
--       },
--       workspace = {
--         -- Make the server aware of Neovim runtime files
--         library = table.insert(vim.api.nvim_get_runtime_file("", true), { vim.fs.normalize(vim.fn.stdpath("config") .. "/lua")}),
--       },
--       -- Do not send telemetry data containing a randomized but unique identifier
--       telemetry = {
--         enable = false,
--       },
--     },
--   },
-- }
--
-- lspconfig['rust_analyzer'].setup{
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
--   -- Server-specific settings...
--   settings = {
--     ["rust-analyzer"] = {}
--   }
-- }
--
-- lspconfig['turtle_ls'].setup{
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
-- }


-- cursor hover on error, faster updatetime
vim.cmd([[set updatetime=1000]])
vim.diagnostic.config({
  virtual_text = false,
})
vim.api.nvim_create_autocmd({ "CursorHold" }, {
	callback = function()
		-- if vim.lsp.buf.server_ready() then
    local _, window_id = vim.diagnostic.open_float({
      focusable = false,
    })
    if(window_id ~= nil) then
      vim.api.nvim_win_call(window_id, function()
        vim.api.nvim_command([[set winblend=30]])
      end)
			-- end
		end
	end,
})

-- set up LSP signs
for type, icon in pairs({
	Error = "",
	Warn = "",
	Hint = "󰌶",
	Info = "",
}) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
