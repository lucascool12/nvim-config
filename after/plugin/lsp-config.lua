require'neodev'.setup()
local nenv = require'neovim-env'

local keymap = vim.keymap.set
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local configs = require('lspconfig/configs')
local util = require('lspconfig/util')
local lspconfig = require'lspconfig'
local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({'*', '.*'}) do
    local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- Fallback to system Python.
  return exepath('python3') or exepath('python') or 'python'
end

local function lsp_keymap_attach (client, bufnr)
	-- lsp-saga
	-- Lsp finder find the symbol definition implement reference
	-- if there is no implement it will hide
	-- when you use action in finder like open vsplit then you can
	-- use <C-t> to jump back
	keymap("n", "<C-f>", "<cmd>Lspsaga finder<CR>", { silent = true })
  keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
	-- Code action -- \ca
	keymap({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })

	-- Peek Definition
	-- you can edit the definition file in this flaotwindow
	-- also support open/vsplit/etc operation check definition_action_keys
	-- support tagstack C-t jump back
	keymap("n", "<C-LeftMouse>", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
	keymap("n", "gD", "<cmd>Lspsaga goto_definition<CR>", { silent = true })

	keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>")
end

local on_attach = function(client, bufnr)
  lsp_keymap_attach(client, bufnr)
  require'signature'.setup(client)
  -- require'lsp-status'.on_attach(client, bufnr)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require'neovim-env'.setup()

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
            library = table.insert(vim.api.nvim_get_runtime_file("", true), { vim.fs.normalize(vim.fn.stdpath("config") .. "/lua")}),
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
    {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      -- Server-specific settings...
      settings = {
        ["rust-analyzer"] = {}
      }
    },
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
	Hint = "",
	Info = "",
}) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
