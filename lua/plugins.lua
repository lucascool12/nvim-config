
return {
  'lervag/vimtex',
  {
    "willothy/flatten.nvim",
    dependencies = { "willothy/wezterm.nvim" },
    opts = function()
      ---@type Terminal?
      local saved_terminal

      return {
        window = {
          open = "alternate",
        },
        callbacks = {
          should_block = function(argv)
            -- Note that argv contains all the parts of the CLI command, including
            -- Neovim's path, commands, options and files.
            -- See: :help v:argv

            -- In this case, we would block if we find the `-b` flag
            -- This allows you to use `nvim -b file1` instead of
            -- `nvim --cmd 'let g:flatten_wait=1' file1`
            return vim.tbl_contains(argv, "-b")

            -- Alternatively, we can block if we find the diff-mode option
            -- return vim.tbl_contains(argv, "-d")
          end,
          pre_open = function()
            local term = require("toggleterm.terminal")
            local termid = term.get_focused_id()
            saved_terminal = term.get(termid)
          end,
          post_open = function(bufnr, winnr, ft, is_blocking)
            if is_blocking and saved_terminal then
              -- Hide the terminal while it's blocking
              saved_terminal:close()
            else
              -- If it's a normal file, just switch to its window
              vim.api.nvim_set_current_win(winnr)

              -- If we're in a different wezterm pane/tab, switch to the current one
              -- Requires willothy/wezterm.nvim
              require("wezterm").switch_pane.id(
              tonumber(os.getenv("WEZTERM_PANE"))
              )
            end

            -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
            -- If you just want the toggleable terminal integration, ignore this bit
            if ft == "gitcommit" or ft == "gitrebase" then
              vim.api.nvim_create_autocmd("BufWritePost", {
                buffer = bufnr,
                once = true,
                callback = vim.schedule_wrap(function()
                  vim.api.nvim_buf_delete(bufnr, {})
                end),
              })
            end
          end,
          block_end = function()
            -- After blocking ends (for a git commit, etc), reopen the terminal
            vim.schedule(function()
              if saved_terminal then
                saved_terminal:open()
                saved_terminal = nil
              end
            end)
          end,
        },
      }
    end,
  },
  -- { 'HiPhish/guile.vim', url='https://gitlab.com/HiPhish/guile.vim'},
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    tag = "v7.0.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.export"] = {},
          ["core.concealer"] = {
            config = {
              folds = false,
            }
          }, -- Adds pretty icons to your documents
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
            },
          },
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes",
              },
            },
          },
        },
      }
    end,
  },
  { 'HiPhish/guile.vim' },
  'lukas-reineke/indent-blankline.nvim',
  'ggandor/leap.nvim',
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  'olimorris/onedarkpro.nvim',
  'j-hui/fidget.nvim',
	'EdenEast/nightfox.nvim',
  'milisims/nvim-luaref',
  'folke/neodev.nvim',
  { 'goerz/jupytext.vim', event = 'VeryLazy' },
  'nvim-lua/plenary.nvim',
  { 'mfussenegger/nvim-dap', event = 'VeryLazy' },
  -- {
  --   'jose-elias-alvarez/null-ls.nvim',
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  -- },
  {
    'mfussenegger/nvim-lint'
  },
	{ 'feline-nvim/feline.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' }},

	'lewis6991/gitsigns.nvim',

	{
		'stevearc/aerial.nvim',
    event = 'VeryLazy',
		config = function() require('aerial').setup() end
  },

	{
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
	},
	{
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
	},
  'nvim-treesitter/playground',
  {
    'akinsho/toggleterm.nvim'
  },
  'neovim/nvim-lspconfig', -- Configurations for Nvim LSP
  {
    'L3MON4D3/LuaSnip',
    version = '2.*',
    build = 'make install_jsregexp'
  },
  'rafamadriz/friendly-snippets',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lua',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'saadparwaiz1/cmp_luasnip',
  'Vimjas/vim-python-pep8-indent',
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    -- or                            , branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
    },
  },
  { 'ThePrimeagen/harpoon', dependencies = 'nvim-lua/plenary.nvim' },
  'BurntSushi/ripgrep',
  ({
    'iamcco/markdown-preview.nvim',
    event = 'VeryLazy',
    run = function() vim.fn['mkdp#util#install']() end,
  }),
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" },
  },
  { 'williamboman/mason.nvim', event = 'VeryLazy' },
  { 'williamboman/mason-lspconfig.nvim', event = 'VeryLazy' },
  { 'windwp/nvim-ts-autotag', event = 'VeryLazy' },
  {
    'gbprod/cutlass.nvim',
    config = function()
      require('cutlass').setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        override_del = true,
        cut_key = 'm'
      })
    end
  },
  'gbprod/yanky.nvim',
  {
    'smjonas/live-command.nvim',
    -- live-command supports semantic versioning via tags
    -- tag = '1.*',
    config = function()
      require('live-command').setup {
        commands = {
          Norm = { cmd = 'norm' },
        },
      }
    end,
  },
}
