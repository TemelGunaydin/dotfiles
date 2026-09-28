-- disable netrw at the very start of your init.lua

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- setup with optimized options
require("nvim-tree").setup({
	on_attach = function(bufnr)
		-- Keep default mappings, then override what we need.
		local api = require("nvim-tree.api")
		api.config.mappings.default_on_attach(bufnr)
	end,
	update_focused_file = {
		enable = true,
		update_cwd = true,
	},
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 50,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})
