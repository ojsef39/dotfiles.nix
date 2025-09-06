return {
	src = "https://github.com/lewis6991/gitsigns.nvim",
	defer = true,
	config = function()
		require("gitsigns").setup()

		-- Keymaps
		vim.keymap.set(
			"n",
			"<leader>gp",
			":Gitsigns preview_hunk_inline<cr>",
			{ desc = "Git Preview changes", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>gt",
			":Gitsigns toggle_current_line_blame<cr>",
			{ desc = "Git Toggle Current Line Blame", silent = true }
		)
		vim.keymap.set("n", "<leader>gb", ":Gitsigns blame<cr>", { desc = "Git Blame", silent = true })
		vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<cr>", { desc = "Git Diff This", silent = true })
	end,
}
