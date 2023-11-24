require "plugins"
require "lsp"


-- Setup color scheme
require('ayu').setup({
    mirage = true,
    overrides = {},
})

-- vim.cmd [[colorscheme ayu-mirage]]
-- vim.cmd [[colorscheme nightfox]]
--
require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = false,
    comments = false,
    operators = false,
    folds = false,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])


-- General
vim.g.mapleader =";"

vim.cmd [[ map <C-t> :tabnew<CR> ]]

vim.api.nvim_set_keymap("n", "<leader>nn", ":NERDTreeMirror<CR>:NERDTreeFocus<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>nf", ":NERDTreeFind<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>fr", "<cmd>Telescope registers<cr>", {noremap = true})

vim.api.nvim_set_keymap("n", "<leader>U", ":UndotreeToggle<CR>", {noremap = true})

vim.cmd [[ autocmd BufWritePre * :%s/\s\+$//e ]]  -- Remove trailing whitespace
vim.cmd [[ au BufRead,BufNewFile *.make set syntax=make ]]

vim.wo.number = true
vim.api.nvim_command('set mouse=a')
vim.api.nvim_command('set undofile')
vim.api.nvim_command('set clipboard+=unnamedplus')
vim.opt.hlsearch = false
vim.opt.incsearch = true
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
vim.api.nvim_command('set scrolloff=8')
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
vim.api.nvim_command('set relativenumber')
vim.opt.updatetime = 50
vim.wo.colorcolumn = ""

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])


vim.opt["smartindent"] = true
vim.opt["wrap"] = true


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

-- Setup telescope
require('telescope').setup{ defaults = { file_ignore_patterns = {
  "node_modules", "yarn.lock", "chunk.js", "chunk.js.map", "requirements.txt"
}}}


-- Setup treesitter
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

require 'nvim-treesitter.install'.compilers = { 'zig' }

configs.setup({
  ensure_installed = "all", -- one of "all" or a list of languages
  sync_install = true,
  ignore_install = { "phpdoc", "agda", "htmldjango" }, -- List of parsers to ignore installing
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

indent_blankline.setup({
  show_current_context = true,
})

-- Setup bufferline
local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

function mysplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end

  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
    return t[#t]
end


local function getParentPath(path)
  pattern1 = "^(.+)//"
  pattern2 = "^(.+)\\"

  if (string.match(path,pattern1) == nil) then
    return mysplit(string.match(path,pattern2), "\\")
  else
    return mysplit(string.match(path,pattern1), "//")
  end
end

bufferline.setup {
  options = {
    mode = "tabs", -- set to "tabs" to only show tabpages instead
    numbers = "ordinal",
    --indicator_icon = '',
    indicator = { style = "icon", icon = "" },
    buffer_close_icon = '',
    modified_icon = '',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 100,
    max_prefix_length = 18, -- prefix used when a buffer is de-duplicated
    tab_size = 20,
    diagnostics = false,
    diagnostics_update_in_insert = false,
    color_icons = false, -- whether or not to add the filetype icon highlights
    show_buffer_icons = false, -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    --[[ show_buffer_default_icon = false, -- whether or not an unrecognised filetype should show a default icon ]]
    show_close_icon = false,
    show_tab_indicators = false,
    separator_style = "thin",
    enforce_regular_tabs = false,
    name_formatter = function(tab)  -- tab contains a "name", "path" and "tabnr"
      if (tab.path == "") then
        return ""
      end

      if (tab.name == "[No Name]") then
        return ""
      end

      return string.format("%s/%s", getParentPath(tab.path), tab.name)
    end,
    custom_filter = function(buf_number, buf_numbers)
      -- don't switch buffer names for these tools
      if
        vim.bo[buf_number].filetype ~= 'nerdtree'
        and vim.bo[buf_number].filetype ~= 'TelescopePrompt'
        and vim.bo[buf_number].filetype ~= 'packer'
      then
        return true
      else
        return false
      end
    end,
  }
}
vim.api.nvim_set_keymap("n", "<leader>gb", ":BufferLinePick<CR>", {noremap = true})

--[[ my pc can't handle this :( ]]
require'treesitter-context'.setup{
  enable = false,
}
