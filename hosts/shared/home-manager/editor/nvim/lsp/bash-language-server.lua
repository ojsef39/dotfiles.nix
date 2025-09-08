---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "nodePackages.bash-language-server", "--run", "bash-language-server start --stdio" },
	filetypes = { "sh", "bash", "zsh" },
	root_markers = {
		".bashrc",
		".bash_profile",
		".git",
		"src",
	},
}
