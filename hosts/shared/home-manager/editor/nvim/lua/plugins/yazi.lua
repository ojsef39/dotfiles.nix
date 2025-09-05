return {
	"mikavilpas/yazi.nvim",
	lazy = true,
	version = "*", -- use the latest stable version
	event = "VimEnter",
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
	},
	keys = {
		{
			-- Open in the current working directory
			"<leader>e",
			function()
				local ok, err = pcall(function()
					vim.cmd("Yazi toggle")
				end)
				if not ok then
					vim.notify("Yazi error (try again): " .. err, vim.log.levels.WARN)
				end
			end,
			desc = "Open the file manager in nvim's working directory",
		},
	},
	opts = {
		open_for_directories = true,
		yazi_floating_window_border = "rounded",
		env = {
			SKIP_FF = "1",
		},
	},
	-- 👇 if you use `open_for_directories=true`, this is recommended
	init = function()
		-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
		-- Block netrw plugin load
		-- vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
}
