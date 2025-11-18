vim.pack.add({ { src = "https://github.com/NickvanDyke/opencode.nvim" } })

vim.g.opencode_opts = {}

vim.o.autoread = true

vim.keymap.set({ "n", "x" }, "<C-a>", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask OpenCode", silent = true })

vim.keymap.set({ "n", "x" }, "<C-x>", function()
	require("opencode").select()
end, { desc = "Execute OpenCode action", silent = true })

vim.keymap.set({ "n", "x" }, "ga", function()
	require("opencode").prompt("@this")
end, { desc = "Add to OpenCode", silent = true })

-- Alternative increment/decrement (since <C-a> and <C-x> are remapped)
vim.keymap.set("n", "<C-+>", "<C-a>", { desc = "Increment", noremap = true, silent = true })
vim.keymap.set("n", "<C-->", "<C-x>", { desc = "Decrement", noremap = true, silent = true })
