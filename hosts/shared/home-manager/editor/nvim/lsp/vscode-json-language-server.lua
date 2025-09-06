---@type vim.lsp.Config
return {
	cmd = {
		"nix-shell",
		"-p",
		"nodePackages.vscode-langservers-extracted",
		"--run",
		"vscode-json-language-server --stdio",
	},
	filetypes = { "json", "jsonc" },
	root_markers = {
		"package.json",
		".git",
		"src",
	},
}
