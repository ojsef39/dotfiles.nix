-- Essential options first
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Show whitespace
vim.opt.list = true
vim.opt.listchars = { space = " ", trail = "⋅", tab = "  ↦" }

vim.opt.foldmethod = "manual"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.breakindent = true

-- Case insensitive searching UNLESS /C or the search has capitals.
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmode = false
vim.opt.wildignore:append({ ".DS_Store" })

-- Status line.
vim.opt.cmdheight = 0
vim.opt.laststatus = 3

vim.opt.textwidth = 160
vim.opt.colorcolumn = "0"

vim.opt.winborder = "rounded"

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes:1"
vim.opt.isfname:append("@-@")

vim.opt.numberwidth = 3
vim.opt.statuscolumn = ""

vim.opt.shortmess:remove("S")

-- Indentation and tab settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Diff mode settings
vim.opt.diffopt:append("algorithm:histogram,indent-heuristic")
vim.opt.diffopt:append("filler,closeoff,vertical")

-- File and backup settings
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- [[ Filetypes ]]
vim.filetype.add({
	pattern = {
		[".*/templates/.*%.yaml"] = "helm",
		[".*%.base"] = "yaml",
	},
})

-- Split settings
vim.opt.splitright = true -- Vertical splits open on the right
