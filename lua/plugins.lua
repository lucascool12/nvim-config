
return {
  'lukas-reineke/indent-blankline.nvim',
  'ggandor/leap.nvim',
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  'olimorris/onedarkpro.nvim',
  'j-hui/fidget.nvim',
  -- 'nvim-lua/lsp-status.nvim',
	"EdenEast/nightfox.nvim",
  'milisims/nvim-luaref',
  "folke/neodev.nvim",
  'goerz/jupytext.vim',
  "nvim-lua/plenary.nvim",
  'mfussenegger/nvim-dap',
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    }
  },
  {
    "mrbjarksen/neo-tree-diagnostics.nvim",
    dependencies = "nvim-neo-tree/neo-tree.nvim",
    module = "neo-tree.sources.diagnostics", -- if wanting to lazyload
  },

  's1n7ax/nvim-window-picker',

	-- use {
	-- 	'nvim-lualine/lualine.nvim',
	-- 	dependencies = { 'kyazdani42/nvim-web-devicons', opt = true }
	-- }
  'feline-nvim/feline.nvim',
	{'romgrk/barbar.nvim', wants = 'nvim-web-devicons'},

	'lewis6991/gitsigns.nvim',

	{
		'stevearc/aerial.nvim',
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
    "L3MON4D3/LuaSnip",
    version = "2.*",
    build = "make install_jsregexp"
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
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    -- or                            , branch = '0.1.x',
    dependencies = { {'nvim-lua/plenary.nvim'} }
  },
  'BurntSushi/ripgrep',
  ({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  }),
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'windwp/nvim-ts-autotag',
  {
    'nvimdev/lspsaga.nvim',
    config = function()
      require("lspsaga").setup({
      })
    end,
  },
  {
    "gbprod/cutlass.nvim",
    config = function()
      require("cutlass").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        override_del = true,
        cut_key = "m"
      })
    end
  },
  'gbprod/yanky.nvim',
  {
    "smjonas/live-command.nvim",
    -- live-command supports semantic versioning via tags
    -- tag = "1.*",
    config = function()
      require("live-command").setup {
        commands = {
          Norm = { cmd = "norm" },
        },
      }
    end,
  },
  {"shortcuts/no-neck-pain.nvim", version = "*" },
}
