local lualine = require("lualine")
local palette = require("tgunaydin.theme").palette

local theme = {
	normal = {
		a = { bg = palette.blue, fg = palette.bg, gui = "bold" },
		b = { bg = palette.bg_highlight, fg = palette.fg },
		c = { bg = palette.bg, fg = palette.fg_dim },
	},
	insert = {
		a = { bg = palette.green, fg = palette.bg, gui = "bold" },
		b = { bg = palette.bg_highlight, fg = palette.green },
		c = { bg = palette.bg, fg = palette.fg_dim },
	},
	visual = {
		a = { bg = palette.violet, fg = palette.bg, gui = "bold" },
		b = { bg = palette.bg_highlight, fg = palette.violet },
		c = { bg = palette.bg, fg = palette.fg_dim },
	},
	replace = {
		a = { bg = palette.red, fg = palette.bg, gui = "bold" },
		b = { bg = palette.bg_highlight, fg = palette.red },
		c = { bg = palette.bg, fg = palette.fg_dim },
	},
	command = {
		a = { bg = palette.accent, fg = palette.bg, gui = "bold" },
		b = { bg = palette.bg_highlight, fg = palette.accent },
		c = { bg = palette.bg, fg = palette.fg_dim },
	},
	inactive = {
		a = { bg = palette.bg_dark, fg = palette.comment },
		b = { bg = palette.bg_dark, fg = palette.comment },
		c = { bg = palette.bg_dark, fg = palette.comment },
	},
}

lualine.setup({
	options = {
		icons_enabled = true,
		theme = theme,
		globalstatus = true,
		section_separators = { left = "", right = "" },
		component_separators = { left = "│", right = "│" },
		disabled_filetypes = {},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = {
			{
				"filename",
				file_status = true, -- displays file status (readonly status, modified status)
				path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
			},
		},
		lualine_x = {
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = { error = " ", warn = " ", info = " ", hint = " " },
			},
			"encoding",
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{
				"filename",
				file_status = true, -- displays file status (readonly status, modified status)
				path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
			},
		},
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = { "fugitive" },
})
-- lualine.setup({
-- 	options = {
-- 		icons_enabled = true,
-- 		theme = "auto",
-- 		component_separators = { left = "", right = "" },
-- 		section_separators = { left = "", right = "" },
-- 		disabled_filetypes = {
-- 			statusline = {},
-- 			winbar = {},
-- 		},
-- 		ignore_focus = {},
-- 		always_divide_middle = true,
-- 		always_show_tabline = true,
-- 		globalstatus = false,
-- 		refresh = {
-- 			statusline = 100,
-- 			tabline = 100,
-- 			winbar = 100,
-- 		},
-- 	},
-- 	sections = {
-- 		lualine_a = { "mode" },
-- 		lualine_b = { "branch", "diff", "diagnostics" },
-- 		lualine_c = { "filename" },
-- 		lualine_x = { "encoding", "fileformat", "filetype" },
-- 		lualine_y = { "progress" },
-- 		lualine_z = { "location" },
-- 	},
-- 	inactive_sections = {
-- 		lualine_a = {},
-- 		lualine_b = {},
-- 		lualine_c = { "filename" },
-- 		lualine_x = { "location" },
-- 		lualine_y = {},
-- 		lualine_z = {},
-- 	},
-- 	tabline = {},
-- 	winbar = {},
-- 	inactive_winbar = {},
-- 	extensions = {},
-- })
