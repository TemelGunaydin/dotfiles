local terminal

local function build_and_run()
	vim.cmd.write()
	local file = vim.api.nvim_buf_get_name(0)
	local directory = vim.fn.fnamemodify(file, ":h")
	local output = directory .. "/.build/" .. vim.fn.fnamemodify(file, ":t:r")
	local escape = vim.fn.shellescape

	if terminal then
		terminal:shutdown()
	end
	terminal = require("toggleterm.terminal").Terminal:new({
		cmd = "mkdir -p " .. escape(directory .. "/.build") .. " && swiftc " .. escape(file) .. " -o " .. escape(
			output
		) .. " && " .. escape(output),
		dir = directory,
		direction = "horizontal",
		close_on_exit = false,
	})
	terminal:open()
end

vim.keymap.set("n", "<F5>", build_and_run, { buffer = true, desc = "Build and run Swift file" })
vim.keymap.set("n", "<leader>rr", build_and_run, { buffer = true, desc = "Build and run Swift file" })
