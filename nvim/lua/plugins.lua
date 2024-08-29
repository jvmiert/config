local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})


return packer.startup(function(use)
  -- My plugins here
  use({ "wbthomason/packer.nvim" }) -- Have packer manage itself
  use({ "windwp/nvim-autopairs" }) -- Autopairs, integrates with both cmp and treesitter
  use({ "numToStr/Comment.nvim" })
  use({ "JoosepAlviste/nvim-ts-context-commentstring" })
  use({ "nvim-lua/plenary.nvim" })
  use({ "lukas-reineke/indent-blankline.nvim" })

  use({'mbbill/undotree'})

  use({ "preservim/nerdtree" })
  use {
    'nvim-telescope/telescope.nvim', branch = 'master',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Colorschemes
  use({ "Shatur/neovim-ayu" })
  use({ "sonph/onehalf", rtp = 'vim' })
  use({ "ellisonleao/gruvbox.nvim" })
  use({ "EdenEast/nightfox.nvim" })
  use({ "rebelot/kanagawa.nvim" })

  -- LSP
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  }
  use({ "jose-elias-alvarez/null-ls.nvim" }) -- for formatters and linters

  -- Treesitter
  use({ "nvim-treesitter/nvim-treesitter" })

  use {'akinsho/bufferline.nvim', tag = "v4.*" }


  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
