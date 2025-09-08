---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "rust-analyzer", "--run", "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = {
		"Cargo.toml",
		"rust-project.json",
		".git",
		"src",
	},
}
