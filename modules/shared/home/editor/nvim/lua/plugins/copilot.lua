vim.pack.add({ { src = "https://github.com/zbirenbaum/copilot.lua" } })

require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<C-j>",
			accept_word = "<C-l>",
			accept_line = "<C-k>",
			next = "<C-n>",
			prev = "<C-p>",
			dismiss = "<C-h>",
		},
	},
	filetypes = {
		["*"] = true, -- Enable for ALL filetypes by default
		help = false,
		gitrebase = false,
		hgcommit = false,
		svn = false,
		cvs = false,
	},
	should_attach = function(_, bufname)
		if string.match(bufname, "%.env") then
			return false
		end
		return true
	end,
})

-- Manual keymap setup to override any conflicts
vim.keymap.set("i", "<C-j>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").accept()
	else
		return "<C-j>"
	end
end, { expr = true, silent = true, desc = "Accept Copilot suggestion" })

vim.keymap.set("i", "<C-l>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").accept_word()
	else
		return "<C-l>"
	end
end, { expr = true, silent = true, desc = "Accept Copilot word" })

vim.keymap.set("i", "<C-k>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").accept_line()
	else
		return "<C-k>"
	end
end, { expr = true, silent = true, desc = "Accept Copilot line" })

vim.keymap.set("i", "<C-n>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").next()
	else
		return "<C-n>"
	end
end, { expr = true, silent = true, desc = "Next Copilot suggestion" })

vim.keymap.set("i", "<C-p>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").prev()
	else
		return "<C-p>"
	end
end, { expr = true, silent = true, desc = "Previous Copilot suggestion" })

vim.keymap.set("i", "<C-h>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").dismiss()
	else
		return "<C-h>"
	end
end, { expr = true, silent = true, desc = "Dismiss Copilot suggestion" })
