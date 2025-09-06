-- Set up autocommands to attach to lsp
local lsp_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h") .. "/../../lsp"

-- Load LSPs dynamically from the lsp directory
for _, file in ipairs(vim.fn.readdir(lsp_dir)) do
	local lsp_name = file:match("(.+)%.lua$")
	if lsp_name then
		local ok, err = pcall(vim.lsp.enable, lsp_name)
		if not ok then
			vim.notify(string.format("Failed to load LSP: %s\nError: %s", lsp_name, err), vim.log.levels.WARN, {
				title = "LSP Load Error",
				icon = "󰅚 ",
				timeout = 5000,
			})
		end
	end
end

vim.lsp.inlay_hint.enable(true)

-- Diagnostic configuration.
vim.diagnostic.config({
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = tools.ui.diagnostics.ERROR,
			[vim.diagnostic.severity.HINT] = tools.ui.diagnostics.HINT,
			[vim.diagnostic.severity.INFO] = tools.ui.diagnostics.INFO,
			[vim.diagnostic.severity.WARN] = tools.ui.diagnostics.WARN,
		},
	},
	virtual_text = {
		prefix = "",
		spacing = 2,
		source = "if_many",
		-- Sort diagnostics by severity (errors first)
		format = function(diagnostic)
			return diagnostic.message
		end,
	},
	float = {
		source = "if_many",
		-- Show severity icons as prefixes.
		prefix = function(diag)
			local level = vim.diagnostic.severity[diag.severity]
			local prefix = string.format("%s ", tools.ui.diagnostics[level])
			return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
		end,
	},
})
