---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "metals", "--run", "metals" },
	filetypes = { "scala" },
	root_markers = {
		".git",
		"src",
		"build.sbt",
	},
}
