---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "-p", "metals", "--run", "metals" },
	filetypes = { "scala" },
	root_markers = {
		".git",
		"src",
		"build.sbt",
	},
}
