local mason = require("mason")
mason.setup({})

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
	-- Replace the language servers listed here with the ones you want to install
	ensure_installed = {},
	handlers = {},
})

-- Install formatters and linters
local mason_tool_installer = require("mason-tool-installer")
mason_tool_installer.setup({
	ensure_installed = {
		"prettierd",
		"htmlbeautifier",
		"black",
	},
	auto_update = false,
	run_on_start = true,
})
