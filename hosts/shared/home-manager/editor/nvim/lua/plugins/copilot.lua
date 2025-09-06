return {
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 75,
					keymap = {
						accept = "<C-j>",
						accept_word = "<C-l>",
						accept_line = "<C-k>",
						next = "<C-n>",
						prev = "<C-p>",
						dismiss = "<C-h>",
					},
				},
				filetypes = {
					["*"] = true, -- Enable for ALL filetypes by default
					help = false,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
				},
				should_attach = function(_, bufname)
					if string.match(bufname, "%.env") then
						return false
					end
					return true
				end,
			})
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		cmd = "CopilotChat",
		build = function()
			if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
				return "make tiktoken"
			end
		end,
		opts = {
			model = "claude-sonnet-4",
			window = {
				layout = "vertical",
				width = 0.25, -- Smaller width (25% of screen)
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
		},
		keys = {
			{
				"<leader>ap",
				function()
					return require("CopilotChat").toggle()
				end,
				desc = "Toggle Copilot Chat",
				mode = { "n", "v" },
			},
			{
				"<leader>ax",
				function()
					return require("CopilotChat").reset()
				end,
				desc = "Clear Copilot Chat",
				mode = { "n", "v" },
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
				end,
			})

			chat.setup(opts)
		end,
	},
}
