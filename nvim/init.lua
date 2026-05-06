vim.opt.clipboard:append({ "unnamed", "unnamedplus" }) -- Use system clipboard by default

vim.opt.hlsearch = true -- Highlight matches while searching
vim.opt.ignorecase = true -- Ignore case while searching, by default
vim.opt.incsearch = true -- Enable incremental search by default

vim.opt.expandtab = true -- Use spaces by default instead of tabs
vim.opt.tabstop = 2 -- How wide a tab looks when displayed
vim.opt.shiftwidth = 2 -- How many spaces to indent by
vim.opt.softtabstop = 2 -- How many spaces to insert when pressing TAB
vim.opt.smartindent = true --
vim.opt.wrap = true --

vim.opt.signcolumn = "yes" -- Fixed left column width for lsp diag.

vim.opt.number = true -- Enable line numbers
vim.opt.rnu = true -- Make the line numbers relative

vim.opt.scrolloff = 8 --

vim.opt.swapfile = false --
vim.opt.backup = false --
vim.opt.undofile = true --

vim.g.mapleader = ";" -- Set ; as the leader key

vim.keymap.set("n", "<leader>6", "<C-^>")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true
	end,
})

-- Post install hooks
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
		if name == "fff.nvim" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("fff.nvim")
			end
			require("fff.download").download_or_build_binary()
		end

		if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
			vim.system({ "make" }, { cwd = ev.data.path })
		end

		if name == "blink.cmp" and (kind == "install" or kind == "update") then
			vim.notify("Installing blink............")
			local result = vim.system({ "cargo", "build", "--release" }, { cwd = path }):wait(60000)

			vim.notify("Blink build code result: " .. result.code)
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/ellisonleao/gruvbox.nvim" },
	{
		src = "https://github.com/ThePrimeagen/harpoon",
		version = "harpoon2",
	},
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range("0.1.x") },
	{ src = "https://github.com/dmtrKovalenko/fff.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

	{ src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/saghen/blink.cmp" },
})

vim.api.nvim_create_user_command("PackUpdate", "lua vim.pack.update()", {})

require("blink.cmp").build()
require("blink.cmp").setup({
	completion = {
		menu = {
			auto_show = false,
		},
		ghost_text = {
			enabled = false,
		},
	},
	keymap = {
		preset = "default",
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
	cmdline = {
		completion = { menu = { auto_show = false } },
	},
})

require("gruvbox").setup({
	italic = {
		strings = false,
		comments = false,
		operators = false,
		folds = false,
	},
})

vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")

vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		})
	end,
	settings = {
		Lua = {
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "space",
					indent_size = "2",
				},
			},
		},
	},
})

vim.lsp.enable("ruff")
vim.lsp.enable("lua_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("jsonls")
vim.lsp.enable("oxlint")

local harpoon = require("harpoon")
harpoon.setup()
vim.keymap.set("n", "<leader>A", function()
	harpoon:list():prepend()
end)
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<C-h>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-t>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-n>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-s>", function()
	harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)

local telescopeConfig = require("telescope.config")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

require("telescope").setup({
	defaults = {
		vimgrep_arguments = vimgrep_arguments,
		preview = {
			filesize_limit = 0.1, -- MB
		},
		pickers = {
			find_files = {
				-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
				find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
			},
		},
	},
})
require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")
-- vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })

local trouble = require("trouble")
trouble.setup({ focus = false })

vim.keymap.set("n", "<leader>tt", function()
	require("trouble").toggle({ mode = "diagnostics" })
end)
vim.keymap.set("n", "[t", function()
	require("trouble").next({ mode = "diagnostics" })
end)
vim.keymap.set("n", "]t", function()
	require("trouble").prev({ mode = "diagnostics" })
end)

vim.g.fff = {
	lazy_sync = true, -- start syncing only when the picker is open
	debug = {
		enabled = true,
		show_scores = true,
	},
}

vim.keymap.set("n", "<leader>ff", function()
	require("fff").find_files()
end, { desc = "FFFind files" })
vim.keymap.set("n", "<leader>fg", function()
	require("fff").live_grep()
end, { desc = "LiFFFe grep" })

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
		javascript = { "oxfmt", stop_after_first = true },
		javascriptreact = { "oxfmt", stop_after_first = true },
		typescript = { "oxfmt", stop_after_first = true },
		typescriptreact = { "oxfmt", stop_after_first = true },
		html = { "oxfmt", stop_after_first = true },
		css = { "oxfmt", stop_after_first = true },
		nix = { "alejandra" },
		json = { "jq" },
		["*"] = { "trim_whitespace" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

require("nvim-treesitter").install({
	"javascript",
	"typescript",
	"lua",
	"nix",
	"nu",
	"tsx",
	"json",
	"css",
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter.setup", {}),
	callback = function(args)
		local buf = args.buf
		local filetype = args.match

		-- you need some mechanism to avoid running on buffers that do not
		-- correspond to a language (like oil.nvim buffers), this implementation
		-- checks if a parser exists for the current language
		local language = vim.treesitter.language.get_lang(filetype) or filetype
		if not vim.treesitter.language.add(language) then
			return
		end

		-- replicate `highlight = { enable = true }`
		vim.treesitter.start(buf, language)

		-- replicate `indent = { enable = true }`
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
