require'neodev'.setup()
require'mason-lspconfig'.setup()

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

function lsp_keymap_attach (client, bufnr)
	-- lsp-saga
	-- Lsp finder find the symbol definition implement reference
	-- if there is no implement it will hide
	-- when you use action in finder like open vsplit then you can
	-- use <C-t> to jump back
	keymap("n", "<C-f>", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
  keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
	-- Code action -- \ca
	keymap({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })

	-- Peek Definition
	-- you can edit the definition file in this flaotwindow
	-- also support open/vsplit/etc operation check definition_action_keys
	-- support tagstack C-t jump back
	keymap("n", "<C-LeftMouse>", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

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

local function mason_ensure_installed(servers)
  local mason_reg = require'mason-registry'
  for _, server in ipairs(servers) do
    if not mason_reg.is_installed(server) then
      vim.cmd("MasonInstall " .. server)
    end
  end
end
--
-- vim.api.nvim_create_user_command("MasonInstallPip3rdPlugins", function (t)
--   local package = t.fargs[1]
--   local plugin = t.fargs[2]
--   local mr = require'mason-registry'
--   local path_package = mr.get_package(package):get_install_path()
--   local pip_venv = vim.fs.normalize(path_package .. "/venv/bin/pip")
--   local install_cmd = pip_venv .. " install " .. plugin
--   local output = vim.fn.system(install_cmd)
--   if vim.v.shell_error ~= 0 then
--     print("Install: " .. plugin .. "failed:" .. output)
--     print("command used: " .. install_cmd)
--   end
-- end,
-- {
--   nargs = "+",
-- })
--

local ensure_installed = {'lua-language-server', 'rust-analyzer', 'pyright'}
mason_ensure_installed(ensure_installed)

require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function (server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
    }
  end,
  ["pylsp"] = function ()
    lspconfig['pylsp'].setup{
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
    }
  end,
  ["rust_analyzer"] = function ()
    lspconfig['rust_analyzer'].setup{
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      -- Server-specific settings...
      settings = {
        ["rust-analyzer"] = {}
      }
    }
  end,
  ["lua_ls"] = function()
    require'lspconfig'['lua_ls'].setup {
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
    }
  end,
  ["pyright"] = function ()
    lspconfig['pyright'].setup{
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
    }
  end,
}


lspconfig['turtle_ls'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- cursor hover on error, faster updatetime
vim.cmd([[set updatetime=1000]])
vim.diagnostic.config({
  virtual_text = false,
})
vim.api.nvim_create_autocmd({ "CursorHold" }, {
	callback = function()
		if vim.lsp.buf.server_ready() then
			local _, window_id = vim.diagnostic.open_float({
				focusable = false,
			})
			if(window_id ~= nil) then
				vim.api.nvim_win_call(window_id, function()
					vim.api.nvim_command([[set winblend=30]])
				end)
			end
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
