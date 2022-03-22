call plug#begin('~/AppData/Local/nvim/plugged')

Plug 'rstacruz/vim-closer'
Plug 'Luxed/ayu-vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'

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
set scrolloff=5
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
nnoremap <leader>fb <cmd>Telescope buffers<cr>

nmap <leader>cd :cd %:h<CR>
nmap <leader>lcd :lcd %:h<CR>

autocmd BufWritePre * :%s/\s\+$//e

au BufRead,BufNewFile *.make set syntax=make

:let g:NERDTreeWinSize=45
:let g:NERDTreeQuitOnOpen=1
:let g:NERDTreeShowHidden=1

lua << EOF
require('telescope').setup{ defaults = { file_ignore_patterns = {
  "node_modules", "yarn.lock", "chunk.js", "chunk.js.map", "requirements.txt"
}}}

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

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.proto = {
  install_info = {
    url = "https://github.com/mitchellh/tree-sitter-proto", -- local path or git repo
    files = {"src/parser.c"},
    branch = "main",
  },
  filetype = "proto", -- if filetype does not agrees with parser name
}

local lsp_config = require('lspconfig')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  if client.name ~= 'efm' then
    client.resolved_capabilities.document_formatting = false
  end

  if client.resolved_capabilities.document_formatting then
    vim.cmd [[
        augroup Format
          au! * <buffer>
          au BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync(nil, 2000)
        augroup END
      ]]
  end

end

local eslint = {
    lintCommand = 'eslint_d --stdin --stdin-filename ${INPUT} -f visualstudio',
    lintStdin = true,
    lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
    lintIgnoreExitCode = true,
    formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
}
local prettier = { formatCommand = 'prettierd ${INPUT}', formatStdin = true }
local flake8 = {
  lintCommand = 'flake8 --stdin-display-name ${INPUT} -',
  lintStdin = true,
  lintIgnoreExitCode = true,
  lintFormats = {'%f:%l:%c: %m'},
}

local efm_root_markers = {'package.json'}
local efm_languages = {
    javascript = {eslint, prettier},
    javascriptreact = {eslint, prettier},
    ["javascript.jsx"] = {eslint, prettier},
    typescript = {eslint, prettier},
    typescriptreact = {eslint, prettier},
    ["typescript.tsx"] = {eslint, prettier},
    svelte = {eslint, prettier},
    python = {flake8},
}

lsp_config.efm.setup{
    filetypes = vim.tbl_keys(efm_languages),
    on_attach = on_attach,
    root_dir = lsp_config.util.root_pattern('package.json', 'requirements.txt'),
    init_options = {documentFormatting = true},
    settings = {rootMarkers = efm_root_markers, languages = efm_languages}
}

lsp_config.tsserver.setup{
  on_attach = on_attach,
}

lsp_config.gopls.setup{
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
    },
  },
}

lsp_config.cmake.setup{
  on_attach = on_attach,
}

lsp_config.pyright.setup{
  on_attach = on_attach,
  root_dir = lsp_config.util.root_pattern(".git", "setup.py",  "setup.cfg", "pyproject.toml", "requirements.txt")
}

lsp_config.clangd.setup{
  on_attach = on_attach,
}
EOF
