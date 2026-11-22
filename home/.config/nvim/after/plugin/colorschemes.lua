-- myColorscheme = "kanagawa-dragon"
myColorscheme = "xcodedark"
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
-- Yorumlardaki italik efektini kaldırmak için global ayar
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("tgunaydin_comment_style", { clear = true }),
	pattern = "*",
	callback = function()
		for _, group in ipairs({ "Comment", "@comment" }) do
			local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
			highlight.italic = false
			vim.api.nvim_set_hl(0, group, highlight)
		end
	end,
})

local ok = pcall(vim.cmd.colorscheme, myColorscheme)
if not ok then
	vim.notify("Colorscheme '" .. myColorscheme .. "' not found", vim.log.levels.WARN)
end
