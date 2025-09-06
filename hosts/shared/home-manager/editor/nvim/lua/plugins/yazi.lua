return {
	src = "https://github.com/mikavilpas/yazi.nvim",
	defer = true,
	dependencies = {
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
	},
	config = function()
		-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
		-- Block netrw plugin load
		-- vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("yazi").setup({
			open_for_directories = true,
			yazi_floating_window_border = "rounded",
			env = {
				SKIP_FF = "1",
			},
		})
		-- Keymaps
		vim.keymap.set("n", "<leader>e", function()
			local ok, err = pcall(function()
				vim.cmd("Yazi toggle")
			end)
			if not ok then
				vim.notify("Yazi error (try again): " .. err, vim.log.levels.WARN)
			end
		end, { desc = "Open the file manager in nvim's working directory", silent = true })
	end,
}
