return {
	src = "https://github.com/stevearc/conform.nvim",
	defer = true,
	config = function()
		-- Install conform formatters on VeryLazy
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		require("conform").setup({
			default_format_opts = {
				timeout_ms = 3000,
				async = false, -- not recommended to change
				quiet = false, -- not recommended to change
			},
			formatters_by_ft = {
				["markdown.mdx"] = { "prettier", "markdownlint-cli2" },
				css = { "prettier" },
				fish = { "fish_indent" },
				go = { "gofumpt", "goimports-reviser" },
				graphql = { "prettier" },
				handlebars = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				json5 = { "prettier" },
				jsonc = { "prettier" },
				less = { "prettier" },
				lua = { "stylua" },
				markdown = { "prettier", "markdownlint-cli2" },
				nix = { "alejandra" },
				python = { "isort", "black" },
				rust = { "rustfmt" },
				scss = { "prettier" },
				sh = { "shfmt" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				yaml = { "prettier" },
				dockerfile = { "dockerfmt" },
			},
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 3000,
			},
			format_after_save = {
				lsp_fallback = true,
			},
			log_level = vim.log.levels.ERROR,
			notify_on_error = true,
			notify_no_formatters = true,
			formatters = {
				injected = { options = { ignore_errors = true } },
			},
		})

		-- Global toggle for conform
		_G.conform_enabled = true

		-- Toggle function
		local function toggle_conform()
			_G.conform_enabled = not _G.conform_enabled
			if _G.conform_enabled then
				print("Conform enabled")
			else
				print("Conform disabled - using LSP formatting")
			end
		end

		-- Override format function to check toggle
		local original_format = require("conform").format
		require("conform").format = function(opts)
			opts = opts or {}
			if not _G.conform_enabled then
				return vim.lsp.buf.format(opts)
			end
			return original_format(opts)
		end

		-- Keymaps
		vim.keymap.set({ "n", "v" }, "<leader>cF", function()
			require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
		end, { desc = "Format Injected Langs", silent = true })

		vim.keymap.set("n", "<leader>ct", toggle_conform, { desc = "Toggle Conform", silent = true })
	end,
}
