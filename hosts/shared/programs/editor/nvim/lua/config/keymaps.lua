-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- remap redo to U
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo", noremap = false })

-- Rearrange visually selected lines in normal mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { silent = true })

-- Select and replace
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Open diagnostics in a floating window
local opts = {
  focusable = false,
  close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
  border = "rounded",
  source = "always",
  prefix = " ",
  scope = "cursor",
}
vim.keymap.set(
  "n",
  "E",
  ":lua vim.diagnostic.open_float(nil, opts) <cr>",
  { desc = "Floating Error thingy", silent = true }
)

-- Add text navigation keymaps
-- Terminal key mappings for Alt/Option + arrows (word navigation)
vim.keymap.set("n", "<M-Left>", "b", { noremap = true })
vim.keymap.set("n", "<M-Right>", "w", { noremap = true })
vim.keymap.set("i", "<M-Left>", "<C-o>b", { noremap = true })
vim.keymap.set("i", "<M-Right>", "<C-o>w", { noremap = true })

