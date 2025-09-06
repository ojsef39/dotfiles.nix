return {
	"coder/claudecode.nvim",
	cmd = {
		"ClaudeCode",
		"ClaudeCodeFocus",
		"ClaudeCodeSelectModel",
		"ClaudeCodeAdd",
		"ClaudeCodeSend",
		"ClaudeCodeTreeAdd",
		"ClaudeCodeDiffAccept",
		"ClaudeCodeDiffDeny",
	},
	config = function()
		require("claudecode").setup({})
	end,
	keys = {
		-- AI commands under <leader>a
		{ "<leader>a", "", desc = "AI" },
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeSend<cr>",
			mode = "v",
			desc = "Send selection to Claude",
		},
		{ "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude diff" },

		-- Quick access
		{ "<C-,>", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code", mode = { "n", "x" } },
	},
}
