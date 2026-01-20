vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
})

tools.on_pack_changed("blink.cmp", function(ev)
	vim.system({ "nix run .#build-plugin" }, { cwd = ev.data.path })
end, { kinds = { "install", "update" } })

require("blink.cmp").setup({
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
				--auto_show = true,
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
})
