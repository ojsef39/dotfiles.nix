return {
	"ruifm/gitlinker.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("gitlinker").setup({
			opts = {
				add_current_line_on_normal_mode = true,
				action_callback = require("gitlinker.actions").open_in_browser,
				print_url = true,
			},
		})
	end,
	keys = {
		{
			"<leader>go",
			function()
				require("gitlinker").get_buf_range_url("n")
			end,
			desc = "Git Browse (open in browser)",
		},
		{
			"<leader>gy",
			function()
				require("gitlinker").get_buf_range_url(
					"n",
					{ action_callback = require("gitlinker.actions").copy_to_clipboard }
				)
			end,
			desc = "Git Copy URL",
		},
		{
			"<leader>go",
			function()
				require("gitlinker").get_buf_range_url("v")
			end,
			mode = "v",
			desc = "Git Browse selection",
		},
		{
			"<leader>gy",
			function()
				require("gitlinker").get_buf_range_url(
					"v",
					{ action_callback = require("gitlinker.actions").copy_to_clipboard }
				)
			end,
			mode = "v",
			desc = "Git Copy selection URL",
		},
	},
}
