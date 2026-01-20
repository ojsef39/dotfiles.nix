vim.pack.add({
	{ src = "https://github.com/OXY2DEV/markview.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("markview").setup({
	preview = {
		icon_provider = "mini", -- "mini" or "devicons" or "internal"
	},
})
