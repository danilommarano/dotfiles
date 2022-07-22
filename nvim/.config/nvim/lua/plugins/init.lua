return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Project tree view
  use 'preservim/nerdtree'

  -- Authomaticaly handle parentheses, quotes, XML tags and much more
  use 'tpope/vim-surround'

  -- Comments everything
  use 'tpope/vim-commentary'

  -- Git integration
  use 'tpope/vim-fugitive'

  -- Shows a git diff in the sign column.
  use 'airblade/vim-gitgutter'

  -- Simple way to use emojis
  use 'terroo/vim-simple-emoji'

  -- Display informations at the bottom of the window
  use 'vim-airline/vim-airline'

  -- Highlight all trailing whitespace charaters
  use 'ntpeters/vim-better-whitespace'

  -- Enhanced JavaScript Syntax
  use 'jelera/vim-javascript-syntax'

  -- Markdoow Viewer
  use 'tpope/vim-markdown'

  -- LSP
  use 'nvim-treesitter/nvim-treesitter'
  use "williamboman/nvim-lsp-installer"
  use "neovim/nvim-lspconfig"

  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-fzy-native.nvim'

  -- Theme
  use {'morhetz/gruvbox', as = 'gruvbox'}
end)
