vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- remap redo to shift-u
vim.keymap.set("n", "U", "<c-r>", { desc = "redo", noremap = false })

-- Key mappings for LSP actions
vim.keymap.set("n", "<leader>lD", vim.diagnostic.setloclist, { desc = "Diagnostic Loclist" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "<leader>lr", function()
	MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "LSP References" })
vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "ca", vim.lsp.buf.code_action)

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Move selected lines with shift+j or shift+k
-- Replaced by mini.move
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines with shift+j", silent = true })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines with shift+k", silent = true })

-- Duplicate a line and comment out the first line
vim.keymap.set("n", "yc", function()
	vim.api.nvim_feedkeys("yygccp", "m", false)
end, { desc = "Duplicate a line and comment out the first line", silent = true })

-- scroll up half a screen in normal mode, keeping the cursor in the same position
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "scroll up half a screen" })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "scroll down half a screen" })

-- move to the next search result and center the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "move to next search result" })

-- move to the previous search result and center the screen
vim.keymap.set("n", "N", "Nzzzv", { desc = "move to previous search result" }) -- Fixed duplicate 'n' mapping

-- delete selected text in normal and visual mode without affecting the system clipboard
vim.keymap.set("v", "<leader>d", [["_d]], { desc = "delete without affecting clipboard" })

-- search and replace in the whole file with confirmation, case-insensitive, and whole-word
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<c-r><c-w>\>/<c-r><c-w>/gc<left><left><left>]],
	{ desc = "search and replace word" }
)

-- search and replace selected text in visual mode
vim.keymap.set(
	"v",
	"<leader>s",
	[["zy:%s/<c-r>z/<c-r>z/gc<left><left><left>]],
	{ desc = "search and replace selection" }
)

vim.keymap.set("n", "<Tab>", ":bnext<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprev<cr>", { noremap = true, silent = true })

-- Tabs
vim.keymap.set("n", "<leader>t", ":tabnew<cr>", { desc = "New Tab", noremap = true, silent = true })
vim.keymap.set("n", "<leader>x", ":tabclose<cr>", { desc = "Close Tab", noremap = true, silent = true })
vim.keymap.set("n", "<leader>j", ":tabprevious<cr>", { desc = "Prev Tab", noremap = true, silent = true })
vim.keymap.set("n", "<leader>k", ":tabnext<cr>", { desc = "Next Tab", noremap = true, silent = true })

-- Window splits
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split Vertical", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split Horizontal", noremap = true, silent = true })
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close Split", noremap = true, silent = true })
vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Close Other Splits", noremap = true, silent = true })
vim.keymap.set("n", "<leader>wx", "<C-w>x", { desc = "Exchange Splits", noremap = true, silent = true })

-- Toggle boolean values (true/false, True/False)
local function toggle_bool()
	local word = vim.fn.expand("<cword>")
	local line = vim.fn.getline(".")
	local col = vim.fn.col(".")

	-- Find the start and end of the current word
	local start_pos = vim.fn.searchpos("\\<" .. word .. "\\>", "bcnW", vim.fn.line("."))
	local end_pos = vim.fn.searchpos("\\<" .. word .. "\\>", "cenW", vim.fn.line("."))

	if start_pos[1] == 0 or start_pos[2] == 0 or end_pos[1] == 0 or end_pos[2] == 0 then
		print("No boolean word found under cursor")
		return
	end

	local replacement = ""

	-- Check what the current word is and set replacement
	if word == "true" then
		replacement = "false"
	elseif word == "false" then
		replacement = "true"
	elseif word == "True" then
		replacement = "False"
	elseif word == "False" then
		replacement = "True"
	else
		print("Word under cursor is not a boolean value")
		return
	end

	-- Replace the word
	local new_line = string.sub(line, 1, start_pos[2] - 1) .. replacement .. string.sub(line, end_pos[2] + 1)
	vim.fn.setline(".", new_line)

	-- Position cursor at the beginning of the replaced word
	vim.fn.cursor(vim.fn.line("."), start_pos[2])
end

vim.keymap.set("n", "yt", toggle_bool, { desc = "Toggle boolean value" })

-- Move selected lines with Shift+Up/Down in visual mode
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })

-- Indent in visual mode and keep selection
vim.keymap.set("v", "<", "<gv", { silent = true, desc = "Indent left and keep selection" })
vim.keymap.set("v", ">", ">gv", { silent = true, desc = "Indent right and keep selection" })
