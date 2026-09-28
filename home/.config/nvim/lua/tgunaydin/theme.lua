local M = {}

M.palette = {
	bg = "#18181b",
	bg_dark = "#111113",
	bg_soft = "#1d1d20",
	bg_highlight = "#24242a",
	bg_visual = "#2b3b4a",
	fg = "#c9c7bd",
	fg_dim = "#a8a39a",
	comment = "#737b72",
	border = "#3a3a42",
	accent = "#d0b985",
	blue = "#8aa8b2",
	green = "#91a982",
	red = "#d36c67",
	yellow = "#d6a45f",
	aqua = "#8fb5ad",
	violet = "#9a97b7",
	orange = "#c19a7f",
}

function M.setup_kanagawa()
	local palette = M.palette

	require("kanagawa").setup({
		compile = false,
		undercurl = true,
		commentStyle = { italic = false },
		functionStyle = {},
		keywordStyle = { italic = false },
		statementStyle = { bold = false },
		typeStyle = {},
		transparent = false,
		dimInactive = false,
		terminalColors = true,
		theme = "dragon",
		background = {
			dark = "dragon",
			light = "lotus",
		},
		colors = {
			palette = {
				dragonBlack0 = palette.bg_dark,
				dragonBlack1 = "#141417",
				dragonBlack2 = "#19191d",
				dragonBlack3 = palette.bg,
				dragonBlack4 = palette.bg_highlight,
				dragonBlack5 = "#303038",
				dragonWhite = palette.fg,
				dragonGray = palette.fg_dim,
				dragonAsh = palette.comment,
				dragonBlue2 = palette.blue,
				dragonViolet = palette.violet,
				dragonGreen2 = palette.green,
				dragonYellow = palette.accent,
				dragonRed = palette.red,
				dragonAqua = palette.aqua,
				dragonOrange = palette.orange,
			},
			theme = {
				dragon = {
					ui = {
						fg = palette.fg,
						fg_dim = palette.fg_dim,
						bg = palette.bg,
						bg_m3 = palette.bg_dark,
						bg_m2 = "#141417",
						bg_m1 = "#19191d",
						bg_p1 = palette.bg_highlight,
						bg_p2 = "#303038",
						bg_gutter = palette.bg,
						nontext = "#5f655f",
						whitespace = "#3a3a40",
						bg_visual = palette.bg_visual,
						bg_search = "#3a4b5e",
						pmenu = {
							bg = "#202026",
							bg_sel = palette.bg_visual,
							fg = palette.fg,
							fg_sel = "none",
							bg_sbar = "#202026",
							bg_thumb = palette.border,
						},
						float = {
							bg = "#141417",
							fg = palette.fg,
							fg_border = "#545a57",
							bg_border = "#141417",
						},
					},
					syn = {
						comment = palette.comment,
					},
					diag = {
						error = palette.red,
						warning = palette.yellow,
						info = "#7da7c7",
						hint = palette.aqua,
						ok = palette.green,
					},
				},
			},
		},
		overrides = function(colors)
			local theme = colors.theme

			return {
				NormalFloat = { bg = theme.ui.float.bg, fg = theme.ui.float.fg },
				FloatBorder = { bg = theme.ui.float.bg, fg = theme.ui.float.fg_border },
				FloatTitle = { bg = theme.ui.float.bg, fg = theme.syn.identifier, bold = true },
				WinSeparator = { fg = palette.border },

				CursorLine = { bg = "#222226" },
				CursorLineNr = { fg = theme.syn.identifier, bold = true },
				LineNr = { fg = "#5f655f" },
				SignColumn = { bg = theme.ui.bg },
				FoldColumn = { bg = theme.ui.bg, fg = "#5f655f" },
				Folded = { bg = theme.ui.bg_p1, fg = theme.ui.fg_dim },
				Visual = { bg = theme.ui.bg_visual },
				Search = { bg = theme.ui.bg_search, fg = theme.ui.fg },
				IncSearch = { bg = theme.syn.identifier, fg = theme.ui.bg, bold = true },

				Pmenu = { bg = theme.ui.pmenu.bg, fg = theme.ui.pmenu.fg },
				PmenuSel = { bg = theme.ui.pmenu.bg_sel, fg = theme.ui.fg, bold = true },
				PmenuSbar = { bg = theme.ui.pmenu.bg_sbar },
				PmenuThumb = { bg = theme.ui.pmenu.bg_thumb },

				DiagnosticVirtualTextError = { fg = theme.diag.error },
				DiagnosticVirtualTextWarn = { fg = theme.diag.warning },
				DiagnosticVirtualTextInfo = { fg = theme.diag.info },
				DiagnosticVirtualTextHint = { fg = theme.diag.hint },
				DiagnosticUnderlineError = { undercurl = true, sp = theme.diag.error },
				DiagnosticUnderlineWarn = { undercurl = true, sp = theme.diag.warning },
				DiagnosticUnderlineInfo = { undercurl = true, sp = theme.diag.info },
				DiagnosticUnderlineHint = { undercurl = true, sp = theme.diag.hint },

				BlinkCmpMenu = { bg = theme.ui.pmenu.bg, fg = theme.ui.pmenu.fg },
				BlinkCmpMenuSelection = { bg = theme.ui.pmenu.bg_sel, fg = theme.ui.fg, bold = true },
				BlinkCmpDoc = { bg = theme.ui.float.bg, fg = theme.ui.float.fg },
				BlinkCmpDocBorder = { bg = theme.ui.float.bg, fg = theme.ui.float.fg_border },
				BlinkCmpSignatureHelp = { bg = theme.ui.float.bg, fg = theme.ui.float.fg },
				BlinkCmpSignatureHelpBorder = { bg = theme.ui.float.bg, fg = theme.ui.float.fg_border },

				NvimTreeNormal = { bg = palette.bg_dark, fg = theme.ui.fg },
				NvimTreeNormalNC = { bg = palette.bg_dark, fg = theme.ui.fg },
				NvimTreeWinSeparator = { bg = palette.bg_dark, fg = palette.border },
				NvimTreeCursorLine = { bg = palette.bg_highlight },
				NvimTreeIndentMarker = { fg = palette.border },
			}
		end,
	})
end

return M
