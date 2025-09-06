return {
	src = "https://github.com/mrjones2014/smart-splits.nvim",
	name = "smart-splits",
	data = { build = "./kitty/install-kittens.bash" },
	config = function()
		require("smart-splits").setup()

		-- Keymaps
		local smart_splits = require("smart-splits")

		-- resizing splits
		vim.keymap.set("n", "<A-h>", smart_splits.resize_left, { desc = "Resize Split Left" })
		vim.keymap.set("n", "<A-j>", smart_splits.resize_down, { desc = "Resize Split Down" })
		vim.keymap.set("n", "<A-k>", smart_splits.resize_up, { desc = "Resize Split Up" })
		vim.keymap.set("n", "<A-l>", smart_splits.resize_right, { desc = "Resize Split Right" })

		-- moving between splits
		vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left, { desc = "Move to Split Left" })
		vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down, { desc = "Move to Split Down" })
		vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up, { desc = "Move to Split Up" })
		vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right, { desc = "Move to Split Right" })
		vim.keymap.set("n", "<C-\\>", smart_splits.move_cursor_previous, { desc = "Move to Split Prev" })

		-- swapping buffers between windows
		vim.keymap.set("n", "<leader>wh", smart_splits.swap_buf_left, { desc = "Split Swap Buffer Left" })
		vim.keymap.set("n", "<leader>wj", smart_splits.swap_buf_down, { desc = "Split Swap Buffer Down" })
		vim.keymap.set("n", "<leader>wk", smart_splits.swap_buf_up, { desc = "Split Swap Buffer Up" })
		vim.keymap.set("n", "<leader>wl", smart_splits.swap_buf_right, { desc = "Split Swap Buffer Right" })
	end,
}
