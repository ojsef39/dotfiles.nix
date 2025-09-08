local function get_schemas()
	local ok, schemastore = pcall(require, "schemastore")
	if ok then
		return schemastore.json.schemas()
	end
	return {}
end

---@type vim.lsp.Config
return {
	cmd = {
		"nix-shell",
		"--pure",
		"-p",
		"nodePackages.vscode-langservers-extracted",
		"--run",
		"vscode-json-language-server --stdio",
	},
	filetypes = { "json", "jsonc", "json5" },
	root_markers = {
		"package.json",
		".git",
		"src",
	},
	init_options = {
		provideFormatter = true,
	},
	settings = {
		json = {
			validate = { enable = true },
			format = {
				enable = true,
			},
			schemas = get_schemas(),
		},
	},
	on_attach = function(client, bufnr)
		if vim.bo[bufnr].filetype == "json5" then
			-- Completely disable diagnostics for this client on JSON5 files
			client.server_capabilities.diagnosticProvider = false
		end
	end,
}
