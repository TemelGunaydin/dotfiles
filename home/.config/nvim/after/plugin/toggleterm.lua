require("toggleterm").setup({
	shade_terminals = true,
	size = 10, -- The height of the terminal when it's opened horizontally
	direction = "horizontal", -- Make the terminal appear at the bottom of the screen
	close_on_exit = true, -- Optionally close the terminal when the process exits
	shell = vim.o.shell, -- Use the default shell
})
