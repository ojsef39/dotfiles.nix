return {
	{
		"saghen/blink.cmp",
		lazy = true,
		enabled = true,
		event = "InsertEnter",
		version = "*",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
		},
		opts = {
			keymap = { preset = "super-tab" },
			completion = {
				ghost_text = { enabled = true },
				menu = {
					border = "rounded",
					draw = {
						columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
						components = {
							kind_icon = {
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								-- (optional) use highlights from mini.icons
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
							kind = {
								-- (optional) use highlights from mini.icons
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
					},
				},
				documentation = {
					window = {
						border = "rounded",
						auto_show = true,
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			signature = {
				enabled = true,
				window = { border = "rounded" },
			},
		},
		opts_extend = { "sources.default" },
	},
}
