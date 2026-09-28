require("xcodebuild").setup({
	show_build_progress_bar = false,
	integrations = {
		telescope_nvim = {
			enabled = false,
		},
		fzf_lua = {
			enabled = true,
		},
	},
	logs = {
		auto_open_on_success_tests = false,
		auto_open_on_failed_tests = false,
		auto_open_on_success_build = true, -- Show build logs on success
		auto_open_on_failed_build = true, -- Show build logs on failure
		auto_focus = true, -- Focus on the log window
		auto_close_on_app_launch = false, -- Keep logs open to see runtime output
		only_summary = false, -- Show full output
		-- Enable console output capture
		capture_console_output = true,
		notify = function(message, severity)
			local fidget = require("fidget")
			if progress_handle then
				progress_handle.message = message
				if not message:find("Loading") then
					progress_handle:finish()
					progress_handle = nil
					if vim.trim(message) ~= "" then
						fidget.notify(message, severity)
					end
				end
			else
				fidget.notify(message, severity)
			end
		end,
		notify_progress = function(message)
			local progress = require("fidget.progress")

			if progress_handle then
				progress_handle.title = ""
				progress_handle.message = message
			else
				progress_handle = progress.handle.create({
					message = message,
					lsp_client = {
						name = "xcodebuild.nvim",
					},
				})
			end
		end,
	},
	code_coverage = {
		enabled = true,
	},
})
