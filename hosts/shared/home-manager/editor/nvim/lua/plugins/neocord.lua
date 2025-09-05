return {
	"vyfor/cord.nvim",
	build = ":Cord update",
	lazy = true,
	event = "VeryLazy",
	config = function()
		local errors = {}
		local get_errors = function(bufnr)
			return vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
		end

		-- Debounce error updates
		local timer = vim.uv.new_timer()
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			callback = function()
				timer:stop()
				timer:start(
					500,
					0,
					vim.schedule_wrap(function()
						errors = get_errors(0)
					end)
				)
			end,
		})

		local ignorelist = { "git.mam.dev", "jhofer" }
		local is_ignorelisted = function(opts)
			-- Check workspace name
			for _, item in ipairs(ignorelist) do
				if opts.workspace == item then
					return true
				end
			end
			-- Check git remote
			local remote = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
			for _, item in ipairs(ignorelist) do
				if remote:find(item, 1, true) then
					return true
				end
			end
			return false
		end

		require("cord").setup({
			editor = {
				tooltip = "How do I exit this?",
			},
			idle = {
				details = function(opts)
					return is_ignorelisted(opts) and "Taking a break from a secret workspace"
						or string.format("Taking a break from %s", opts.workspace)
				end,
			},
			text = {
				viewing = function(opts)
					return is_ignorelisted(opts) and "Viewing a file" or ("Viewing " .. opts.filename)
				end,
				editing = function(opts)
					if is_ignorelisted(opts) then
						return "Editing a file"
					else
						return string.format("Editing %s - %s errors", opts.filename, #errors)
					end
				end,
				workspace = function(opts)
					return is_ignorelisted(opts) and "In a secret workspace"
						or string.format("Working on %s", opts.workspace)
				end,
			},
		})
	end,
}
