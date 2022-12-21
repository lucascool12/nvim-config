-- bootstrap Packer
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use "EdenEast/nightfox.nvim"
	use {
    'nvim-tree/nvim-tree.lua',
  	requires = {
    	'nvim-tree/nvim-web-devicons', -- optional, for file icons
  	}
	}

	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}
	use {'romgrk/barbar.nvim', wants = 'nvim-web-devicons'}
	use 'mfussenegger/nvim-lint'

	use {
    'lewis6991/gitsigns.nvim',
  	config = function()
    		require('gitsigns').setup()
  	end
	}

	use {
		'stevearc/aerial.nvim',
		config = function() require('aerial').setup() end
  }

	use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
	}
  use {
    "ray-x/lsp_signature.nvim",
  }

	use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
	}
  use'nvim-treesitter/playground'
  use {
    'akinsho/toggleterm.nvim'
  }
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
  use({"L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*"})
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use({
    "glepnir/lspsaga.nvim",
    branch = "main",
  })
  use 'Vimjas/vim-python-pep8-indent'
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    -- or                            , branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'BurntSushi/ripgrep'
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
	end
)

if packer_bootstrap then
    require('packer').sync()
end

