---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "nodePackages.typescript-language-server", "nodePackages.typescript", "--run", "typescript-language-server --stdio" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
	init_options = {
		hostInfo = "neovim",
	},
}
