require'neodev'.setup()
require("mason").setup()
require'mason-lspconfig'.setup()

local keymap = vim.keymap.set

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lsp_signature_config = {
}

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
  require "lsp_signature".on_attach(lsp_signature_config, bufnr)  -- Note: add in lsp client on-attach
end

local on_attach = function(client, bufnr)
  lsp_keymap_attach(client, bufnr)
  -- require'lsp_signature'.on_attach(lsp_sig_config, bufnr)
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
  -- Next, you can provide a dedicated handler for specific servers.
  -- For example, a handler override for the `rust_analyzer`:
  ["rust_analyzer"] = function ()
    require('lspconfig')['rust_analyzer'].setup{
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      -- Server-specific settings...
      settings = {
        ["rust-analyzer"] = {}
      }
    }
  end,
  ["sumneko_lua"] = function()
    require'lspconfig'.sumneko_lua.setup {
      on_attach = on_attach,
      capabilities = capabilities,
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
            library = vim.api.nvim_get_runtime_file("", true),
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        },
      },
    }
  end,
}


require('lspconfig')['turtle_ls'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}


-- cursor hover on error, faster updatetime
vim.cmd([[set updatetime=1000]])
vim.diagnostic.config({ virtual_text = false })
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

-- lsp-saga
local saga = require('lspsaga')

saga.init_lsp_saga()
