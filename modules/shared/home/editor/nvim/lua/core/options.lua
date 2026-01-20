vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.fileencoding = "utf-8"

-- Show whitespace
vim.opt.list = true
vim.opt.listchars = { space = " ", trail = "⋅", tab = "  ↦" }

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldcolumn = "1"
vim.opt.mouse = "a"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.breakindent = true

-- indent-specific folding
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "yaml", "yml", "nix", "python" },
	callback = function()
		vim.opt_local.foldmethod = "indent"
	end,
})

-- Case insensitive searching UNLESS /C or the search has capitals.
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmode = false
vim.opt.wildignore:append({ ".DS_Store" })

-- Status line.
vim.opt.cmdheight = 1
vim.opt.laststatus = 2

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "helm", "nix", "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

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
		[".*%.base"] = "yaml",
		[".*/templates/.*%.yaml"] = "helm",
		[".*/templates/.*%.yml"] = "helm",
		[".*/templates/.*%.tpl"] = "helm",
		[".*values.*%.yaml"] = "helm",
		[".*values.*%.yml"] = "helm",
		[".*/.*values.*/.*%.yaml"] = "helm",
		[".*/.*values.*/.*%.yml"] = "helm",
		["Chart%.yaml"] = "helm",
		["Chart%.yml"] = "helm",
	},
})

-- Split settings
vim.opt.splitright = true -- Vertical splits open on the right

-- Per-project Shada file support
vim.opt.exrc = true
vim.opt.secure = true
local workspace_path = vim.fn.getcwd()
local cache_dir = vim.fn.stdpath("data")
local unique_id = vim.fn.fnamemodify(workspace_path, ":t") .. "_" .. vim.fn.sha256(workspace_path):sub(1, 8) ---@type string
local shadafile = cache_dir .. "/myshada/" .. unique_id .. ".shada"

vim.opt.shadafile = shadafile

vim.opt.switchbuf = "usetab"

-- Ensure files end with a newline
vim.opt.fixendofline = true
vim.opt.endofline = true
vim.opt.endoffile = true
