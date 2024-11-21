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

-- Map terminal escape sequences in Neovim for both normal and insert modes
-- For CMD+Left/Right (start/end of line)
vim.keymap.set({ "n", "i", "v" }, "<C-a>", "<Home>", { noremap = true })
vim.keymap.set({ "n", "i", "v" }, "<C-e>", "<End>", { noremap = true })

-- For ALT+Left/Right (word navigation)
vim.keymap.set({ "n", "v" }, "<M-b>", "b", { noremap = true })
vim.keymap.set({ "n", "v" }, "<M-f>", "w", { noremap = true })
vim.keymap.set("i", "<M-b>", "<C-Left>", { noremap = true })
vim.keymap.set("i", "<M-f>", "<C-Right>", { noremap = true })

-- Alternative mapping method if the above doesn't work
vim.keymap.set({ "n", "v" }, "<ESC>b", "b", { noremap = true })
vim.keymap.set({ "n", "v" }, "<ESC>f", "w", { noremap = true })
vim.keymap.set("i", "<ESC>b", "<C-Left>", { noremap = true })
vim.keymap.set("i", "<ESC>f", "<C-Right>", { noremap = true })

-- Insert mode specific mappings for start/end of line
vim.keymap.set("i", "<C-a>", "<Home>", { noremap = true })
vim.keymap.set("i", "<C-e>", "<End>", { noremap = true })
