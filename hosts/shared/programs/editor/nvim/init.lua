-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set linelength to 120 with colorcolumn
vim.opt.textwidth = 120
vim.opt.colorcolumn = "120"
vim.cmd("highlight ColorColumn ctermbg=lightgrey guibg=lightgrey")
