return {
	src = "https://github.com/stevearc/conform.nvim",
	defer = true,
	config = function()
		local conform = require("conform")

		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		local function wrap_with_nix(name, spec)
			spec = spec or {}
			-- Force load the formatter first if it doesn't exist
			local ok, builtin_formatter = pcall(require, "conform.formatters." .. name)
			if not ok then
				return
			end

			local formatter = conform.formatters[name] or builtin_formatter

			local function with_nix(def)
				local fmt = vim.deepcopy(def)
				fmt.command = "nix"

				local target = spec.package or name
				local nix_prefix = { "run", "--impure", "nixpkgs#" .. target, "--" }
				if spec.extra_args then
					vim.list_extend(nix_prefix, spec.extra_args)
				end

				if type(def.args) == "function" then
					-- Preserve formatter's original args function (e.g. prettier generates ["--stdin-filepath", "file.json"])
					-- and prepend our nix command to create: ["nix", "run", "nixpkgs#prettier", "--", "--stdin-filepath", "file.json"]
					local original_args = def.args
					fmt.args = function(self, ctx)
						local final_args = vim.deepcopy(nix_prefix)
						local dynamic_args = original_args(self, ctx)
						if dynamic_args then
							vim.list_extend(final_args, dynamic_args)
						end
						return final_args
					end
				else
					local args = vim.deepcopy(nix_prefix)
					if type(def.args) == "table" then
						vim.list_extend(args, def.args)
					end
					fmt.args = args
				end

				-- Apply spec overrides
				if spec.stdin ~= nil then
					fmt.stdin = spec.stdin
				end
				if spec.env then
					fmt.env = spec.env
				end

				return fmt
			end

			if type(formatter) == "function" then
				conform.formatters[name] = function(...)
					local def = formatter(...)
					if type(def) ~= "table" then
						return def
					end
					return with_nix(def)
				end
			else
				conform.formatters[name] = with_nix(formatter)
			end
		end

		local formatter_specs = {
			["goimports-reviser"] = {},
			["markdownlint-cli2"] = { package = "markdownlint-cli2" },
			alejandra = {},
			black = { package = "python3Packages.black" },
			dockerfmt = {},
			fish_indent = { package = "fish", extra_args = { "fish_indent" } },
			gofumpt = {},
			isort = { package = "python3Packages.isort" },
			markdownlint = { package = "markdownlint-cli" },
			prettier = { package = "nodePackages.prettier" },
			rustfmt = {},
			shfmt = {},
			stylua = { extra_args = { "-" } },
			terraform_fmt = {
				package = "terraform",
				extra_args = { "fmt", "-" },
				stdin = true,
				env = { NIXPKGS_ALLOW_UNFREE = "1" },
			},
		}

		for name, spec in pairs(formatter_specs) do
			wrap_with_nix(name, spec)
		end

		conform.setup({
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
			},
			formatters_by_ft = {
				["markdown.mdx"] = { "prettier", "markdownlint-cli2" },
				css = { "prettier" },
				dockerfile = { "dockerfmt" },
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
				terraform = { "terraform_fmt" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				yaml = { "prettier" },
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

		_G.conform_enabled = true

		local function toggle_conform()
			_G.conform_enabled = not _G.conform_enabled
			if _G.conform_enabled then
				print("Conform enabled")
			else
				print("Conform disabled - using LSP formatting")
			end
		end

		local original_format = conform.format
		conform.format = function(opts)
			opts = opts or {}
			if not _G.conform_enabled then
				return vim.lsp.buf.format(opts)
			end
			return original_format(opts)
		end

		vim.keymap.set({ "n", "v" }, "<leader>cF", function()
			conform.format({ formatters = { "injected" }, timeout_ms = 3000 })
		end, { desc = "Format Injected Langs", silent = true })

		vim.keymap.set("n", "<leader>ct", toggle_conform, { desc = "Toggle Conform", silent = true })
	end,
}
