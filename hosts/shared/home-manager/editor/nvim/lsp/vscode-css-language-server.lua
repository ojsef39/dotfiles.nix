---@type vim.lsp.Config
return {
	cmd = {
		"nix-shell",
		"-p",
		"nodePackages.vscode-langservers-extracted",
		"--run",
		"vscode-css-language-server --stdio",
	},
	filetypes = { "css", "scss", "less" },
	root_markers = {
		"package.json",
		".git",
		"src",
	},
}
