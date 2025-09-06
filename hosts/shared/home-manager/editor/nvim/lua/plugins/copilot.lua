return {
	src = "https://github.com/zbirenbaum/copilot.lua",
	defer = false,
	config = function()
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
	end,
}
