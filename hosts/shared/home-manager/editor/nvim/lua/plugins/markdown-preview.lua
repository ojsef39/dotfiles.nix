return {
	src = "https://github.com/iamcco/markdown-preview.nvim",
	defer = true,
	data = { build = ":call mkdp#util#install()" },
	config = function()
		vim.g.mkdp_filetypes = { "markdown", "rst" }

		-- Keymaps
		vim.keymap.set(
			{ "n", "v" },
			"<leader>mm",
			"<cmd>MarkdownPreviewToggle<CR>",
			{ desc = "Toggle preview", silent = true }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>mp",
			"<cmd>MarkdownPreview<CR>",
			{ desc = "Start preview", silent = true }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ms",
			"<cmd>MarkdownPreviewStop<CR>",
			{ desc = "Stop preview", silent = true }
		)
	end,
}
