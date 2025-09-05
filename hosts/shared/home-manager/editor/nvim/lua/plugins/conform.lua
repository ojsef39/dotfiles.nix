return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cF",
			function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end,
			mode = { "n", "v" },
			desc = "Format Injected Langs",
		},
	},
	init = function()
		-- Install conform formatters on VeryLazy
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
	opts = {
		default_format_opts = {
			timeout_ms = 3000,
			async = false, -- not recommended to change
			quiet = false, -- not recommended to change
		},
		formatters_by_ft = {
			css = { "prettier" },
			fish = { "fish_indent" },
			go = { "gofumpt", "goimports-reviser" },
			graphql = { "prettier" },
			handlebars = { "prettier" },
			html = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			less = { "prettier" },
			lua = { "stylua" },
			markdown = { "prettier", "markdownlint-cli2" },
			["markdown.mdx"] = { "prettier", "markdownlint-cli2" },
			python = { "isort", "black" },
			rust = { "rustfmt" },
			scss = { "prettier" },
			sh = { "shfmt" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			vue = { "prettier" },
			yaml = { "prettier" },
			nix = { "alejandra" },
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
	},
}
