return {
	"SmiteshP/nvim-navic",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	opts = {
		lsp = {
			auto_attach = true,
		},
		separator = " › ",
		depth_limit = 0,
		safe_output = true,
	},
}
