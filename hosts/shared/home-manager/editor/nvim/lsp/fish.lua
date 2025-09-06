---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "-p", "fish-lsp", "--run", "fish-lsp start" },
	filetypes = { "fish" },
	root_markers = {
		".git",
		"src",
	},
}
