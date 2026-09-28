myColorscheme = "kanagawa-dragon"
-- myColorscheme = "xcodedark"
-- myColorscheme = "miasma"
-- myColorscheme = "neosolarized"
-- myColorscheme = "kanagawa-dragon"
-- myColorscheme = "gruvbox-material"
-- myColorscheme = "menguless"
-- myColorscheme = "atlas"
-- myColorscheme = "alabaster"
-- myColorscheme = "distilled"
-- myColorscheme = "accent"
-- myColorscheme = "solarized"
-- myColorscheme = "solarized-osaka"
-- myColorscheme = "poimandres"
-- myColorscheme = "solarized"
--Burasi packer icindeki colorscheme icine config function olarakta eklenebilir. Ama burasi daha evrensel gibi geldi.
-- vim.g.gruvbox_material_enable_italic = true
-- vim.g.gruvbox_material_background = 'hard'

-- vim.cmd("colorscheme phoenix")
-- vim.cmd("PhoenixYellow")

-- vim.cmd.colorscheme(myColorscheme)
-- usttekine gore alternatif ama daha guvenilir.
local palette = require("tgunaydin.theme").palette

-- Yorumlardaki italik efektini kaldırmak için global ayar
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "Comment", { italic = false, fg = palette.comment })
		vim.api.nvim_set_hl(0, "@comment", { italic = false, fg = palette.comment })
		vim.api.nvim_set_hl(0, "Normal", { fg = palette.fg, bg = palette.bg })
		vim.api.nvim_set_hl(0, "NormalNC", { fg = palette.fg_dim, bg = palette.bg })
	end,
})

local ok = pcall(vim.cmd.colorscheme, myColorscheme)
if not ok then
	vim.notify("Colorscheme '" .. myColorscheme .. "' not found", vim.log.levels.WARN)
end
