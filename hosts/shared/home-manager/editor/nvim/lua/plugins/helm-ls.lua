vim.pack.add({ { src = "https://github.com/qvalentin/helm-ls.nvim" } })

require("helm-ls").setup({
	conceal_templates = {
		-- enable the replacement of templates with virtual text of their current values
		enabled = true,
	},
	indent_hints = {
		-- enable hints for indent and nindent functions
		enabled = true,
		-- show the hints only for the line the cursor is on
		only_for_current_line = true,
	},
})
