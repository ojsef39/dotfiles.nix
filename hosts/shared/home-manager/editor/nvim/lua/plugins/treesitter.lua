return {
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	name = "nvim-treesitter",
	defer = true,
	priority = 100,
	-- data = { build = ":TSUpdate" },
	config = function()
		local opts = {
			highlight = { enable = true },
			indent = { enable = true },
			auto_install = true,
			ensure_installed = {
				"markdown_inline",
				"markdown",
				"css",
				"html",
				"javascript",
				"norg",
				"scss",
				"svelte",
				"tsx",
				"typst",
				"vue",
				"regex",
				"lua",
				"diff",
				"bash",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					scope_incremental = false,
					node_incremental = "v",
					node_decremental = "V",
				},
			},
			textobjects = {
				move = {
					enable = true,
					goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
					goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
					goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
				},
			},
		}

		if type(opts.ensure_installed) == "table" then
			---@type table<string, boolean>
			local added = {}
			opts.ensure_installed = vim.tbl_filter(function(lang)
				if added[lang] then
					return false
				end
				added[lang] = true
				return true
			end, opts.ensure_installed)
		end
		require("nvim-treesitter.configs").setup(opts)

		-- Fully disable treesitter attach for LaTeX buffers
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "tex",
			callback = function(ctx)
				-- ctx.buf is the buffer number
				require("nvim-treesitter.configs").setup({
					highlight = { enable = false },
					indent = { enable = false },
				})
				-- Or: stop treesitter in that buffer only
				vim.treesitter.stop(ctx.buf)
			end,
		})

		-- Keymaps
		vim.keymap.set({ "n", "x" }, "<c-space>", function()
			require("nvim-treesitter.incremental_selection").init_selection()
		end, { desc = "Increment selection", silent = true })
		vim.keymap.set("x", "<bs>", function()
			require("nvim-treesitter.incremental_selection").node_decremental()
		end, { desc = "Decrement selection", silent = true })
	end,
}
