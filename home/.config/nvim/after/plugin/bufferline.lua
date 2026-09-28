vim.opt.termguicolors = true

local palette = require("tgunaydin.theme").palette

local bufferline = require("bufferline")
bufferline.setup({
	options = {
		offsets = {
			{
				filetype = "NvimTree",
				text = "",
				separator = true,
			},
		},
		separator_style = "thin", -- Style for buffer separators
		show_buffer_close_icons = false,
		show_close_icon = false,
		always_show_bufferline = true,
	},
	highlights = {
		fill = {
			bg = palette.bg_dark,
		},
		background = {
			fg = palette.fg_dim,
			bg = palette.bg_dark,
		},
		buffer_visible = {
			fg = palette.fg_dim,
			bg = palette.bg_dark,
		},
		buffer_selected = {
			fg = palette.fg,
			bg = palette.bg_highlight,
			bold = true,
			italic = false,
		},
		numbers_selected = {
			fg = palette.accent,
			bg = palette.bg_highlight,
			bold = true,
			italic = false,
		},
		modified = {
			fg = palette.yellow,
			bg = palette.bg_dark,
		},
		modified_selected = {
			fg = palette.yellow,
			bg = palette.bg_highlight,
		},
		indicator_selected = {
			fg = palette.accent,
			bg = palette.bg_highlight,
		},
		separator = {
			fg = palette.bg_dark,
			bg = palette.bg_dark,
		},
		separator_visible = {
			fg = palette.bg_dark,
			bg = palette.bg_dark,
		},
		separator_selected = {
			fg = palette.bg_dark,
			bg = palette.bg_highlight,
		},
	},
})
