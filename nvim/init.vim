call plug#begin('~/AppData/Local/nvim/plugged')

Plug 'rstacruz/vim-closer'
Plug 'ayu-theme/ayu-vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'

call plug#end()

let mapleader=";"

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

let ayucolor="mirage"
colorscheme ayu

map <C-t> :tabnew<CR>
map <C-[> :tabprevious<CR>
map <C-]> :tabnext<CR>

nnoremap <leader>nn :NERDTreeMirror<CR>:NERDTreeFocus<CR>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>

nmap <leader>cd :cd %:h<CR>
nmap <leader>lcd :lcd %:h<CR>

autocmd BufWritePre * :%s/\s\+$//e

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

au BufRead,BufNewFile *.make set syntax=make

:let g:NERDTreeWinSize=45
:let g:NERDTreeQuitOnOpen=1
:let g:NERDTreeShowHidden=1

lua << EOF
-- Polyfill `vim.lsp.buf.format` from neovim 0.8
--
-- START COPYPASTA https://github.com/neovim/neovim/commit/5b04e46d23b65413d934d812d61d8720b815eb1c
local util = require 'vim.lsp.util'
--- Formats a buffer using the attached (and optionally filtered) language
--- server clients.
---
--- @param options table|nil Optional table which holds the following optional fields:
---     - formatting_options (table|nil):
---         Can be used to specify FormattingOptions. Some unspecified options will be
---         automatically derived from the current Neovim options.
---         @see https://microsoft.github.io/language-server-protocol/specification#textDocument_formatting
---     - timeout_ms (integer|nil, default 1000):
---         Time in milliseconds to block for formatting requests. Formatting requests are current
---         synchronous to prevent editing of the buffer.
---     - bufnr (number|nil):
---         Restrict formatting to the clients attached to the given buffer, defaults to the current
---         buffer (0).
---     - filter (function|nil):
---         Predicate used to filter clients. Receives a client as argument and must return a
---         boolean. Clients matching the predicate are included. Example:
---
---         <pre>
---         -- Never request typescript-language-server for formatting
---         vim.lsp.buf.format {
---           filter = function(client) return client.name ~= "tsserver" end
---         }
---         </pre>
---
---     - id (number|nil):
---         Restrict formatting to the client with ID (client.id) matching this field.
---     - name (string|nil):
---         Restrict formatting to the client with name (client.name) matching this field.
vim.lsp.buf.format = vim.lsp.buf.format or function(options)
  options = options or {}
  local bufnr = options.bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({
    id = options.id,
    bufnr = bufnr,
    name = options.name,
  })

  if options.filter then
    clients = vim.tbl_filter(options.filter, clients)
  elseif options.id then
    clients = vim.tbl_filter(
      function(client) return client.id == options.id end,
      clients
    )
  elseif options.name then
    clients = vim.tbl_filter(
      function(client) return client.name == options.name end,
      clients
    )
  end

  clients = vim.tbl_filter(
    function(client) return client.supports_method 'textDocument/formatting' end,
    clients
  )

  if #clients == 0 then
    vim.notify '[LSP] Format request failed, no matching language servers.'
  end

  local timeout_ms = options.timeout_ms or 1000
  for _, client in pairs(clients) do
    local params = util.make_formatting_params(options.formatting_options)
    local result, err = client.request_sync('textDocument/formatting', params, timeout_ms, bufnr)
    if result and result.result then
      util.apply_text_edits(result.result, bufnr, client.offset_encoding)
    elseif err then
      vim.notify(string.format('[LSP][%s] %s', client.name, err), vim.log.levels.WARN)
    end
  end
end
-- END COPYPASTA


require('telescope').setup{ defaults = { file_ignore_patterns = {
  "node_modules", "yarn.lock", "chunk.js", "chunk.js.map", "requirements.txt"
}}}

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {"phpdoc"}, -- List of parsers to ignore installing
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

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
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
  lintCommand = 'flake8 --ignore=E111 --stdin-display-name ${INPUT} -',
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
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('LspFormatting', { clear = true }),
        pattern = '*',
        callback = function()
          vim.lsp.buf.format {
            timeout_ms = 2000,
          }
        end
      })
      on_attach(client, bufnr)
    end,
    root_dir = lsp_config.util.root_pattern('package.json', 'requirements.txt'),
    init_options = {documentFormatting = true},
    settings = {rootMarkers = efm_root_markers, languages = efm_languages}
}

lsp_config.tsserver.setup{
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider  = false
      client.server_capabilities.document_formatting = false
      client.server_capabilities.documentFormattingProvider = false
      client.resolved_capabilities.document_formatting = false
    end,
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

function OrgImports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end
EOF

autocmd BufWritePre *.go lua OrgImports(1000)

highlight Search ctermbg=yellow ctermfg=black guibg=yellow guifg=black
