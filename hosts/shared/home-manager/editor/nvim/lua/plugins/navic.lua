return {
	src = "https://github.com/SmiteshP/nvim-navic",
	defer = true,
	dependencies = {
		{ src = "https://github.com/neovim/nvim-lspconfig" },
	},
	config = function()
		require("nvim-navic").setup({
			lsp = {
				auto_attach = true,
			},
			separator = " › ",
			depth_limit = 0,
			safe_output = true,
		})
	end,
}
