vim.g.mapleader = " "

vim.keymap.set("n", "R", "mzJ`z")

-- Override `ya{` to yank the whole brace block *linewise*.
-- This includes the line that contains `{` (e.g. `public class Foo {`).
-- Implementation: jump to the opening brace of the current block, then yank to its match.
vim.keymap.set("n", "ya{", "[{V%y", { noremap = true, silent = true })

-- Move selected lines up/down
vim.keymap.set("v", "J", "<cmd>m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", "<cmd>m '<-2<CR>gv=gv")

-- -- <cmd>BufWrite<cr>" ≈ ":BufWrite<CR>" ama daha temiz/hızlı.
-- LspRestart yazmak daha verimli
-- vim.keymap.set("n", "<leader>res", "<cmd>LspRestart<cr>")

-- Insert Mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Dont lose the last pasted
vim.keymap.set("v", "<leader>p", '"_dP')

vim.keymap.set("n", "Q", "<nop>")

-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { silent = true })
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { silent = true })

vim.keymap.set("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- replace yapar
vim.keymap.set("n", "J", "5j", {
	noremap = true,
	silent = true,
})
vim.keymap.set("n", "K", "5k", {
	noremap = true,
	silent = true,
})
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", {
	noremap = true,
	silent = true,
})
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { silent = true })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { silent = true })
vim.keymap.set("n", "<leader>c", "<cmd>Bdelete<cr>", { silent = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz", {
	noremap = true,
	silent = true,
})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {
	noremap = true,
	silent = true,
})

vim.keymap.set("n", "\\", "<cmd>NvimTreeToggle<cr>", { silent = true })

-- ToggleTerm
vim.keymap.set("n", "<leader>te", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
vim.keymap.set("t", "<leader>te", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

-- Dosya icindeki tum texti kopyalar.
vim.keymap.set("n", "<leader>yy", "<cmd>%y +<cr>", { silent = true })

-- Dosya icindeki herseyi highlight yaparak secer
vim.keymap.set("n", "<leader>ya", "ggVG", { silent = true })

local pickers = require("tgunaydin.pickers")

-- fff.nvim (leader only; avoids stealing bare fg/fz/fc)
vim.keymap.set("n", "<leader>ff", pickers.find_files, { desc = "Find files (fff)" })
vim.keymap.set("n", "<leader>fg", pickers.live_grep, { desc = "Live grep (fff)" })
vim.keymap.set("n", "<leader>fz", pickers.live_grep_fuzzy, { desc = "Live grep fuzzy+plain (fff)" })
vim.keymap.set("n", "<leader>fc", pickers.live_grep_current_word, { desc = "Search current word (fff)" })

vim.keymap.set("n", "<leader>st", pickers.current_buffer_search, { desc = "Search current buffer" })
vim.keymap.set("n", "<leader>sb", pickers.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>sc", pickers.colorschemes, { desc = "Colorschemes" })
vim.keymap.set("n", "<leader>sq", pickers.quickfix, { desc = "Quickfix" })
vim.keymap.set("n", "<leader>so", pickers.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>gd", pickers.lsp_definitions, { desc = "Goto definition" })
vim.keymap.set("n", "<leader>gi", pickers.lsp_implementations, { desc = "Goto implementation" })
vim.keymap.set("n", "<leader>go", pickers.lsp_type_definitions, { desc = "Goto type definition" })
vim.keymap.set("n", "<leader>gr", pickers.lsp_references, { desc = "Goto references" })
vim.keymap.set("n", "<leader>sm", pickers.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>sd", pickers.workspace_diagnostics, { desc = "Workspace diagnostics" })

--XCODE
vim.keymap.set("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", {
	desc = "Show Xcodebuild Actions",
})
vim.keymap.set("n", "<leader>xf", "<cmd>XcodebuildProjectManager<cr>", {
	desc = "Show Project Manager Actions",
})

vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", {
	desc = "Build Project",
})
vim.keymap.set("n", "<leader>xB", "<cmd>XcodebuildBuildForTesting<cr>", {
	desc = "Build For Testing",
})
vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", {
	desc = "Build & Run Project",
})

vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", {
	desc = "Run Tests",
})
vim.keymap.set("v", "<leader>xt", "<cmd>XcodebuildTestSelected<cr>", {
	desc = "Run Selected Tests",
})
vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", {
	desc = "Run This Test Class",
})

vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", {
	desc = "Toggle Xcodebuild Logs",
})

vim.keymap.set("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", {
	desc = "Toggle Code Coverage",
})
vim.keymap.set("n", "<leader>xC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", {
	desc = "Show Code Coverage Report",
})
vim.keymap.set("n", "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>", {
	desc = "Toggle Test Explorer",
})
vim.keymap.set("n", "<leader>xs", "<cmd>XcodebuildFailingSnapshots<cr>", {
	desc = "Show Failing Snapshots",
})

vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", {
	desc = "Select Device",
})
vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", {
	desc = "Select Test Plan",
})
vim.keymap.set("n", "<leader>xq", function()
	pickers.quickfix()
end, {
	desc = "Show Quickfix List",
})

vim.keymap.set("n", "<leader>xx", "<cmd>XcodebuildQuickfixLine<cr>", {
	desc = "Quickfix Line",
})
vim.keymap.set("n", "<leader>xa", "<cmd>XcodebuildCodeActions<cr>", {
	desc = "Show Code Actions",
})

-- * ile arama yaparken highlight iptal etmek icin gerekli
vim.keymap.set("n", "<CR>", function()
	-- Don't break the default <CR> behavior in lists like quickfix/location list,
	-- where <CR> is used to jump to the selected item.
	local bt = vim.bo.buftype
	local ft = vim.bo.filetype
	if bt == "quickfix" or ft == "qf" or ft == "trouble" then
		return "<CR>"
	end

	vim.cmd.noh()
	return ""
end, { silent = true, expr = true })

vim.keymap.set(
	"n",
	"<leader>v",
	"<cmd>vsplit<cr>",
	{ noremap = true, silent = true, desc = "Vertical split current file" }
) -- kapatmak icin <C-w>c yapilir.

-- conform plugin ile formatla yapiyoruz.
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	-- eger plugin dogru yuklenirse ok, yoksa hata verir
	local ok, conform = pcall(require, "conform")
	if ok then
		conform.format({ async = true, lsp_fallback = false })
	end
end, { desc = "Format buffer" })
