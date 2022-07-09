require "plugins"
require "lsp"


-- Setup color scheme
require('ayu').setup({
    mirage = true,
    overrides = {},
})

vim.cmd [[colorscheme ayu-mirage]]


-- General
vim.g.mapleader =";"

vim.api.nvim_set_keymap("n", "<C-t>", ":tabnew<CR>", {})
vim.api.nvim_set_keymap("n", "<C-[>", ":tabprevious<CR>", {})
vim.api.nvim_set_keymap("n", "<C-]>", ":tabnext<CR>", {})

vim.api.nvim_set_keymap("n", "<leader>nn", ":NERDTreeMirror<CR>:NERDTreeFocus<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", {noremap = true})

vim.cmd [[ autocmd BufWritePre * :%s/\s\+$//e ]]  -- Remove trailing whitespace
vim.cmd [[ au BufRead,BufNewFile *.make set syntax=make ]]

vim.wo.number = true
vim.api.nvim_command('set mouse=a')
vim.api.nvim_command('set undofile')
vim.api.nvim_command('set clipboard+=unnamedplus')
vim.api.nvim_command('set hlsearch')
vim.api.nvim_command('set ignorecase')
vim.api.nvim_command('set incsearch')
vim.api.nvim_command('set smartcase')
vim.api.nvim_command('set updatetime=250')
vim.api.nvim_command('set signcolumn=number')
vim.api.nvim_command('set autoread')
vim.api.nvim_command('set backspace=2')
vim.api.nvim_command('set colorcolumn=80')
vim.api.nvim_command('set hidden')
vim.api.nvim_command('set laststatus=2')
vim.api.nvim_command('set ruler')
vim.api.nvim_command('set scrolloff=5')
vim.api.nvim_command('set sidescrolloff=5')
vim.api.nvim_command('set showmatch')
vim.api.nvim_command('set showmode')
vim.api.nvim_command('set splitbelow')
vim.api.nvim_command('set splitright')
vim.api.nvim_command('set title')
vim.api.nvim_command('set visualbell')
vim.api.nvim_command('set expandtab')
vim.api.nvim_command('set tabstop=2')
vim.api.nvim_command('set softtabstop=2')
vim.api.nvim_command('set shiftwidth=2')

vim.opt["smartindent"] = true
vim.opt["wrap"] = false


-- Nerd tree stuff
vim.cmd [[ autocmd StdinReadPre * let s:std_in=1 ]]
vim.cmd [[ autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif ]]
vim.cmd [[ :let g:NERDTreeWinSize=45 ]]
vim.cmd [[ :let g:NERDTreeQuitOnOpen=1 ]]
vim.cmd [[ :let g:NERDTreeShowHidden=1 ]]


-- Setup nvim-autopairs.
local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
  return
end

npairs.setup {
  check_ts = true,
  ts_config = {
    lua = { "string", "source" },
    javascript = { "string", "template_string" },
    java = false,
  },
  disable_filetype = { "TelescopePrompt", "spectre_panel" },
  fast_wrap = {
    map = "<M-e>",
    chars = { "{", "[", "(", '"', "'" },
    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
    offset = 0, -- Offset from pattern match
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "PmenuSel",
    highlight_grey = "LineNr",
  },
}


-- Setup comments
local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  return
end

comment.setup {
  pre_hook = function(ctx)
    local U = require "Comment.utils"

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring {
      key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
      location = location,
    }
  end,
}


-- Setup impatient
local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
  return
end

impatient.enable_profile()


-- Setup telescope
require('telescope').setup{ defaults = { file_ignore_patterns = {
  "node_modules", "yarn.lock", "chunk.js", "chunk.js.map", "requirements.txt"
}}}


-- Setup treesitter
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

configs.setup({
  ensure_installed = "all", -- one of "all" or a list of languages
  ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
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
})

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.proto = {
  install_info = {
    url = "https://github.com/mitchellh/tree-sitter-proto", -- local path or git repo
    files = {"src/parser.c"},
    branch = "main",
  },
  filetype = "proto", -- if filetype does not agrees with parser name
}


-- Setup blankline
local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
  return
end

vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
vim.g.indent_blankline_filetype_exclude = {
  "help",
  "packer",
  "NvimTree",
}
vim.g.indentLine_enabled = 1
vim.g.indent_blankline_show_trailing_blankline_indent = false
vim.g.indent_blankline_show_first_indent_level = true
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_current_context = true

-- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
vim.wo.colorcolumn = "99999"

indent_blankline.setup({
  show_current_context = true,
})