vim.pack.add({ { src = "https://github.com/catppuccin/nvim" } })

require("catppuccin").setup({
	flavour = "macchiato",
	transparent_background = true,
	float = {
		transparent = true, -- enable transparent floating windows
		solid = false, -- use solid styling for floating windows, see |winborder|
	},
	show_end_of_buffer = false,
	term_colors = true,
	no_italic = false,
	no_bold = false,
	no_underline = false,
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
	},
	default_integrations = true,
	integrations = {
		gitsigns = true,
		treesitter = true,
		dap = true,
		dap_ui = true,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
	},
})

vim.cmd.colorscheme("catppuccin-macchiato")
local sign = vim.fn.sign_define

sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })

-- manually set some color
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#403d52", bold = false })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#c4a7e7", bold = true })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#403d52", bold = false })
