vim.pack.add({
	{ src = "https://github.com/SmiteshP/nvim-navic" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

require("nvim-navic").setup({
	lsp = {
		auto_attach = true,
	},
	separator = " › ",
	depth_limit = 0,
	safe_output = true,
})
