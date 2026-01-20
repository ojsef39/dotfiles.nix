---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "sourcekit-lsp", "--run", "sourcekit-lsp" },
	filetypes = { "swift" },
	root_markers = {
		".git",
		"src",
		"Package.swift",
	},
}
