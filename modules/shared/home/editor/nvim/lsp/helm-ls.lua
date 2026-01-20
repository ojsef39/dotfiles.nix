local function get_yaml_schemas()
	local ok, schemastore = pcall(require, "schemastore")
	if ok then
		return schemastore.yaml.schemas()
	end
	return {}
end

---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "helm-ls", "nodePackages.yaml-language-server", "--run", "helm_ls serve" },
	filetypes = { "helm", "helmFile" },
	settings = {
		["helm-ls"] = {
			yamlls = {
				enabled = true,
				path = "yaml-language-server",
				config = {
					schemas = vim.tbl_extend("force", {
						kubernetes = "templates/**",
					}, get_yaml_schemas()),
					format = {
						enable = true,
					},
					completion = true,
					hover = true,
					validate = true,
					schemaStore = {
						enable = false,
					},
				},
			},
		},
	},
}
