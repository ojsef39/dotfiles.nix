return {
	src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
	defer = true,
	dependencies = {
		{ src = "https://github.com/zbirenbaum/copilot.lua" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
	},
	data = { build = "make tiktoken" },
	config = function()
		local chat = require("CopilotChat")

		chat.setup({
			model = "claude-sonnet-4",
			window = {
				layout = "vertical",
				width = 0.3, -- Smaller width (30% of screen)
				height = 0.8,
				relative = "editor",
				border = "single",
			},
			chat = {
				welcome_message = false,
			},
			mappings = {
				complete = {
					insert = "",
				},
				reset = {
					normal = "<C-c>",
					insert = "",
				},
				close = {
					normal = "q",
					insert = "",
				},
			},
		})

		-- Autocmd for chat buffer
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "copilot-chat",
			callback = function()
				vim.opt_local.relativenumber = false
				vim.opt_local.number = false
			end,
		})

		-- Keymaps
		vim.keymap.set({ "n", "v" }, "<leader>ap", function()
			return require("CopilotChat").toggle()
		end, { desc = "Toggle Copilot Chat", silent = true })

		vim.keymap.set({ "n", "v" }, "<leader>ax", function()
			return require("CopilotChat").reset()
		end, { desc = "Clear Copilot Chat", silent = true })
	end,
}
