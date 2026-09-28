--nvim-lspconfig icindir.
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	callback = function(args)
		-- vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true })
	end,
})
local blinkCapabilities = require("blink.cmp").get_lsp_capabilities()
-- swift icin ayarlama yaptik.
vim.lsp.config("sourcekit", {
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		},
	},
})
vim.lsp.config("clangd", {
	capabilities = blinkCapabilities,
	cmd = {
		"clangd",
		"--query-driver=/usr/bin/clang,/usr/bin/clang++",
	},
})
vim.lsp.config("tsserver", {
	capabilities = blinkCapabilities,
	cmd = { "typescript-language-server" },
	filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
})

vim.lsp.config("tailwindcss", {
	capabilities = blinkCapabilities,
})

vim.lsp.config("eslint", {
	capabilities = blinkCapabilities,
})

vim.lsp.config("mojo", {
	capabilities = blinkCapabilities,
	cmd = { "mojo-lsp-server" },
	filetypes = { "mojo" },
	single_file_support = true,
})

vim.lsp.enable("tailwindcss")
vim.lsp.enable("tsserver")
vim.lsp.enable("sourcekit")
vim.lsp.enable("eslint")
vim.lsp.enable("clangd")
vim.lsp.enable("mojo")
