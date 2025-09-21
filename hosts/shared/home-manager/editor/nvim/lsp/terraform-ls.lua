---@type vim.lsp.Config
return {
	cmd = { "nix", "run", "--impure", "nixpkgs#terraform-ls", "--", "serve" },
	filetypes = { "terraform", "terraform-vars" },
	root_markers = {
		".terraform",
		".terraform.lock.hcl",
		"terraform.tfstate",
		"terraform.tfstate.backup",
		".git",
		"*.tf",
	},
	env = {
		NIXPKGS_ALLOW_UNFREE = "1",
	},
	settings = {
		terraformls = {
			experimentalFeatures = {
				validateOnSave = true,
				prefillRequiredFields = true,
			},
		},
	},
}