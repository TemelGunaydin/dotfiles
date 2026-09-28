local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } },
			true,
			{}
		)
		vim.fn.getchar()

		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
local treesitter_parsers = {
	"c",
	"lua",
	"swift",
	"python",
	"vim",
	"vimdoc",
	"query",
	"markdown",
	"markdown_inline",
	"javascript",
	"typescript",
	"tsx",
	"toml",
	"fish",
	"php",
	"json",
	"yaml",
	"css",
	"html",
}

local plugins = {
	{ "github/copilot.vim" },
	{
		"dmtrKovalenko/fff.nvim",
		build = function()
			-- this will download prebuild binary or try to use existing rustup toolchain to build from source
			-- (if you are using lazy you can use gb for rebuilding a plugin if needed)
			require("fff.download").download_or_build_binary()
		end,
		-- if you are using nixos
		-- build = "nix run .#release",
		opts = { -- (optional)
			debug = {
				enabled = true, -- we expect your collaboration at least during the beta
				show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
			},
		},
		-- No need to lazy-load with lazy.nvim.
		-- This plugin initializes itself lazily.
		lazy = false,
	},
	{
		"xero/miasma.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"V4N1LLA-1CE/xcodedark.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"pauchiner/pastelnight.nvim",
		lazy = false,
		priority = 1000,
	},
	"nvimdev/lspsaga.nvim",
	"onsails/lspkind.nvim",
	{
		"svrana/neosolarized.nvim",
		lazy = false,
		priority = 1000,
		dependencies = {
			"tjdevries/colorbuddy.nvim",
		},
	},
	"windwp/nvim-ts-autotag",
	"Mofiqul/adwaita.nvim",
	"norcalli/nvim-colorizer.lua",
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
		},
	},
	"ramojus/mellifluous.nvim",
	{ "j-hui/fidget.nvim", version = "*" },
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		-- config = true sadece lazy.nvim’in bu eklenti için “kurulum fonksiyonunu” calistirmasidir
		config = true,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		priority = 1000,
		dependencies = "nvim-tree/nvim-web-devicons",
	},
	"mfussenegger/nvim-lint",
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter").install(treesitter_parsers, { summary = true, max_jobs = 1 }):wait(300000)
		end,
		branch = "main",
		lazy = false,
		config = function()
			local treesitter = require("nvim-treesitter")
			local parser_install_dir = vim.fn.stdpath("data") .. "/site"

			treesitter.setup({
				install_dir = parser_install_dir,
			})

			local group = vim.api.nvim_create_augroup("tgunaydin_treesitter", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				callback = function(args)
					local max = 100 * 1024
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
					if ok and stats and stats.size > max then
						return
					end

					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	"VonHeikemen/fine-cmdline.nvim",
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tgunaydin.theme").setup_kanagawa()
		end,
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	"tpope/vim-fugitive",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"whoissethdaniel/mason-tool-installer.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		event = { "BufReadPre", "BufNewFile" },
	},
	{ --lua dosyasin icin lsp ozelliklerini kullanmamizi saglar.
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = { "ibhagwan/fzf-lua", "MunifTanjim/nui.nvim" },
	},

	"echasnovski/mini.nvim",
	"nvim-lualine/lualine.nvim",
	{
		"akinsho/bufferline.nvim",
		version = "*",
	},
	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	version = false,
	-- 	event = "InsertEnter",
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-path",
	-- 		"hrsh7th/cmp-buffer",
	-- 	},
	-- },
	"famiu/bufdelete.nvim",
	{ "christoomey/vim-tmux-navigator" },
	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
	},

	{
		"saghen/blink.cmp",
		dependencies = "rafamadriz/friendly-snippets",
		version = "1.*",
	},
}

require("lazy").setup(plugins, {})
