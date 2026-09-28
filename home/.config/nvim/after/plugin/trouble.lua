local trouble = require("trouble")
trouble.setup({
	auto_open = false,
	auto_close = false,
	auto_preview = true,
	auto_jump = false,
	mode = "quickfix",
	severity = vim.diagnostic.severity.ERROR,
	cycle_results = false,
})
