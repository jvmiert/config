local servers = { "cmake", "pyright", "clangd", "gopls", "tsserver", "tailwindcss", "rust_analyzer"}

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true
})

local lspconfig = require("lspconfig")
local util = require("lspconfig/util")
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


-- gopls
lsp_config.gopls.setup{
  cmd = {"gopls"},
  filetypes = {"go", "gomod", "gotmpl"},
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
  end,
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


-- cmake
lsp_config.cmake.setup{
  on_attach = on_attach,
}


-- pyright
lsp_config.pyright.setup{
  on_attach = on_attach,
  root_dir = lsp_config.util.root_pattern(".git", "setup.py",  "setup.cfg", "pyproject.toml", "requirements.txt")
}


-- clangd
lsp_config.rust_analyzer.setup{
  on_attach = on_attach,
}

-- rust
lsp_config.clangd.setup{
  on_attach = on_attach,
}


-- typescript
lsp_config.tsserver.setup{
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider  = false
      client.server_capabilities.document_formatting = false
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.document_formatting = false
    end,
}


-- null-ls
local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = false,
    sources = {
      formatting.prettierd,
      diagnostics.eslint_d,
      formatting.gofmt,
      formatting.goimports,
      diagnostics.flake8,
  },
  on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                  vim.lsp.buf.format({
                    bufnr = bufnr,
                    filter = function(client)
                      return client.name == "null-ls"
                    end,
                    timeout_ms = 2000
                  })
              end,
          })
      end
  end,
})
