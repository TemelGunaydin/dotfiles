local conform = require("conform")

-- burda olmalari kurulcaklari anlamina gelmiyor, mason kullanarak kurulmali ya manuel yada UI ile.
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		swift = { "swiftformat" },
		html = { "htmlbeautifier" },
		python = { "isort", "black" },
		cpp = { "clang_format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
