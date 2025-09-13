-- [[ Autocommands ]]

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
	group = augroup("ojsef39/yank_highlight", { clear = true }),
	desc = "Highlight on yank",
	callback = function()
		-- Setting a priority higher than the LSP references one.
		vim.hl.on_yank({ higroup = "Visual", priority = 250 })
	end,
})

autocmd("BufWinEnter", {
	group = augroup("ojsef39/marks", { clear = true }),
	desc = "Show marks in signcolumn",
	callback = function(args)
		require("ui.marks").BufWinEnterHandler(args)
	end,
})
