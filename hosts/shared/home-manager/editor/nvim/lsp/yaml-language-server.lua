local uv = vim.loop
local fn = vim.fn
local root = uv.cwd() -- fallback; you might already use a more advanced root finder

-- Try to read `.yaml-ls.json` from the root directory
local function load_yaml_ls_settings()
	local path = root .. "/.yaml-ls.json"
	if fn.filereadable(path) == 1 then
		local ok, content = pcall(fn.readfile, path)
		if ok then
			local json = fn.json_decode(table.concat(content, "\n"))
			if json then
				return json
			end
		end
	end
	return {}
end

---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "nodePackages.yaml-language-server", "--run", "yaml-language-server --stdio" },
	filetypes = { "yaml", "yml" },
	root_markers = {
		"docker-compose.yml",
		"docker-compose.yaml",
		".git",
		"src",
	},
	settings = vim.tbl_deep_extend("force", {
		yaml = {
			validate = true,
			hover = true,
			completion = true,
			format = {
				enable = true,
			},
		},
	}, load_yaml_ls_settings()),
}
