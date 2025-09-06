return {
	src = "https://github.com/ruifm/gitlinker.nvim",
	defer = true,
	dependencies = {
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
	},
	config = function()
		require("gitlinker").setup({
			opts = {
				add_current_line_on_normal_mode = true,
				action_callback = require("gitlinker.actions").open_in_browser,
				print_url = true,
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>go", function()
			require("gitlinker").get_buf_range_url("n")
		end, { desc = "Git Browse (open in browser)", silent = true })

		vim.keymap.set("n", "<leader>gy", function()
			require("gitlinker").get_buf_range_url(
				"n",
				{ action_callback = require("gitlinker.actions").copy_to_clipboard }
			)
		end, { desc = "Git Copy URL", silent = true })

		vim.keymap.set("v", "<leader>go", function()
			require("gitlinker").get_buf_range_url("v")
		end, { desc = "Git Browse selection", silent = true })

		vim.keymap.set("v", "<leader>gy", function()
			require("gitlinker").get_buf_range_url(
				"v",
				{ action_callback = require("gitlinker.actions").copy_to_clipboard }
			)
		end, { desc = "Git Copy selection URL", silent = true })
	end,
}
