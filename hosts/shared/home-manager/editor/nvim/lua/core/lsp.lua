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

-- Define the diagnostic signs.
for severity, icon in pairs(tools.ui.diagnostics) do
	local hl = "DiagnosticSign" .. severity:sub(1, 1) .. severity:sub(2):lower()
	vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

-- Diagnostic configuration.
vim.diagnostic.config({
	virtual_text = {
		prefix = "",
		spacing = 2,
		format = function(diagnostic)
			-- Use shorter, nicer names for some sources:
			local special_sources = {
				["Lua Diagnostics."] = "lua",
				["Lua Syntax Check."] = "lua",
			}
			local prefix = tools.ui.diagnostics[vim.diagnostic.severity[diagnostic.severity]]
			local message = diagnostic.message
			-- local source = ''
			-- if diagnostic.source then
			--     source = string.format(' (%s)', special_sources[diagnostic.source] or diagnostic.source)
			-- end
			-- local code = ''
			-- if diagnostic.code then
			--     code = string.format('[%s]', diagnostic.code)
			-- end
			-- return string.format('%s%s%s: %s', prefix, source, code, message)
			return string.format("%s %s", prefix, message)
		end,
	},
	float = {
		source = "if_many",
		-- Show severity icons as prefixes.
		prefix = function(diag)
			local level = vim.diagnostic.severity[diag.severity]
			local prefix = string.format(" %s ", diagnostic_icons[level])
			return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
		end,
	},
	-- Disable signs in the gutter.
	signs = false,
})
