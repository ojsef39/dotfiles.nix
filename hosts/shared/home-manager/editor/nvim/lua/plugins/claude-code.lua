return {
	src = "https://github.com/coder/claudecode.nvim",
	defer = true,
	config = function()
		require("claudecode").setup({})

		-- Keymaps
		-- AI commands under <leader>a
		vim.keymap.set("n", "<leader>a", "", { desc = "AI" })
		vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code", silent = true })
		vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude Code", silent = true })
		vim.keymap.set(
			"n",
			"<leader>am",
			"<cmd>ClaudeCodeSelectModel<cr>",
			{ desc = "Select Claude model", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>ab",
			"<cmd>ClaudeCodeAdd %<cr>",
			{ desc = "Add current buffer to Claude", silent = true }
		)
		vim.keymap.set(
			"v",
			"<leader>as",
			"<cmd>ClaudeCodeSend<cr>",
			{ desc = "Send selection to Claude", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>ay",
			"<cmd>ClaudeCodeDiffAccept<cr>",
			{ desc = "Accept Claude diff", silent = true }
		)
		vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff", silent = true })

		-- Quick access
		vim.keymap.set({ "n", "x" }, "<C-,>", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude Code", silent = true })
	end,
}
