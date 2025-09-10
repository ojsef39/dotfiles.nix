return {
	src = "https://github.com/OXY2DEV/markview.nvim",
	defer = true,
	dependencies = {
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	},
	config = function()
		require("markview").setup({
			preview = {
				icon_provider = "mini", -- "mini" or "devicons" or "internal"
			},
		})
	end,
}
