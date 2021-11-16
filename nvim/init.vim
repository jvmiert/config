call plug#begin('~/AppData/Local/nvim/plugged')

Plug 'Luxed/ayu-vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

let mapleader=";"
set guifont=Inconsolata\ for\ Powerline:h11

set relativenumber
set number
set mouse=a
set undofile

set clipboard+=unnamedplus

set hlsearch
set ignorecase
set incsearch
set smartcase

set updatetime=250
set scl=yes

set termguicolors
set background=dark

set autoread
set backspace=2

set colorcolumn=80
set hidden
set laststatus=2
set ruler
set scrolloff=999
set showmatch
set showmode
set splitbelow
set splitright
set title
set visualbell

set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

let g:ayucolor="mirage"
colorscheme ayu

map <C-t> :tabnew<CR>
map <C-c> :tabclose<CR>
map <C-[> :tabprevious<CR>
map <C-]> :tabnext<CR>

nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  rainbow = {
    enable = true,
    colors = require('ayu').rainbow_colors
  },
  indent = {
    enable = true,
  },
}
EOF