local M = {}

local function current_file_constraint()
	local path = vim.api.nvim_buf_get_name(0)

	if path == "" then
		return nil
	end

	return vim.fn.fnamemodify(path, ":.")
end

local function select_from_items(items, opts, on_choice)
	if vim.tbl_isempty(items) then
		vim.notify("No items available", vim.log.levels.INFO)
		return
	end

	vim.ui.select(items, opts, on_choice)
end

function M.find_files()
	require("fff").find_files()
end

function M.live_grep()
	require("fff").live_grep()
end

function M.live_grep_literal()
	require("fff").live_grep({
		grep = {
			modes = { "plain" },
		},
	})
end

function M.live_grep_fuzzy()
	require("fff").live_grep({
		grep = {
			modes = { "fuzzy", "plain" },
		},
	})
end

function M.live_grep_current_word()
	require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end

function M.current_buffer_search()
	local constraint = current_file_constraint()

	if not constraint then
		vim.notify("Current buffer is not backed by a file", vim.log.levels.WARN)
		return
	end

	require("fff").live_grep({
		query = constraint .. " ",
	})
end

function M.buffers()
	local items = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted then
			local name = vim.api.nvim_buf_get_name(buf)
			local label = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
			table.insert(items, {
				buf = buf,
				label = label,
			})
		end
	end

	table.sort(items, function(a, b)
		return a.label:lower() < b.label:lower()
	end)

	select_from_items(items, {
		prompt = "Buffers",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if choice then
			vim.api.nvim_set_current_buf(choice.buf)
		end
	end)
end

function M.oldfiles()
	local seen = {}
	local items = {}

	for _, file in ipairs(vim.v.oldfiles or {}) do
		if file ~= "" and vim.fn.filereadable(file) == 1 and not seen[file] then
			seen[file] = true
			table.insert(items, file)
		end
	end

	-- Prefer a real picker UI (Telescope used to provide this). Keep Telescope disabled
	-- and use fzf-lua if present; otherwise fall back to vim.ui.select.
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		local display = {}
		local idx_by_display = {}
		for i, path in ipairs(items) do
			local label = vim.fn.fnamemodify(path, ":~:.")
			-- Avoid collisions if two paths format to the same label.
			local key = label
			if idx_by_display[key] then
				key = string.format("%s (%d)", label, i)
			end
			display[#display + 1] = key
			idx_by_display[key] = path
		end

		fzf.fzf_exec(display, {
			prompt = "Recent Files> ",
			actions = {
				["default"] = function(selected)
					local choice = selected and selected[1]
					local path = choice and idx_by_display[choice]
					if path then
						vim.cmd.edit(vim.fn.fnameescape(path))
					end
				end,
			},
		})
		return
	end

	select_from_items(items, {
		prompt = "Recent Files",
		format_item = function(item)
			return vim.fn.fnamemodify(item, ":~:.")
		end,
	}, function(choice)
		if choice then
			vim.cmd.edit(vim.fn.fnameescape(choice))
		end
	end)
end

function M.colorschemes()
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		fzf.colorschemes()
		return
	end

	local items = vim.fn.getcompletion("", "color")
	select_from_items(items, {
		prompt = "Colorschemes",
	}, function(choice)
		if choice then
			vim.cmd.colorscheme(choice)
		end
	end)
end

function M.quickfix()
	if vim.tbl_isempty(vim.fn.getqflist()) then
		vim.notify("Quickfix list is empty", vim.log.levels.INFO)
		return
	end

	vim.cmd.copen()
end

function M.workspace_diagnostics()
	vim.diagnostic.setqflist({ open = true })
end

function M.lsp_definitions()
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		fzf.lsp_definitions({ jump1 = true })
		return
	end
	vim.lsp.buf.definition()
end

function M.lsp_implementations()
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		fzf.lsp_implementations({ jump1 = true })
		return
	end
	vim.lsp.buf.implementation()
end

function M.lsp_type_definitions()
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		fzf.lsp_typedefs({ jump1 = true })
		return
	end
	vim.lsp.buf.type_definition()
end

function M.lsp_references()
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		fzf.lsp_references({
			jump1 = true,
			ignore_current_line = true,
		})
		return
	end

	-- Fallback: builtin references (usually opens loclist/qflist)
	vim.lsp.buf.references()
end

function M.lsp_document_symbols()
	local ok, fzf = pcall(require, "fzf-lua")
	if ok then
		fzf.lsp_document_symbols()
		return
	end
	vim.lsp.buf.document_symbol()
end

return M
