---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "fish-lsp", "--run", "fish-lsp start" },
	filetypes = { "fish" },
	root_markers = {
		".git",
		"src",
	},
}
