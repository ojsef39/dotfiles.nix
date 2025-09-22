return {
	src = "https://github.com/mfussenegger/nvim-lint",
	defer = true,
	config = function()
		local lint = require("lint")

		local function wrap_with_nix(name, spec)
			spec = spec or {}
			local module = spec.module or name
			local ok, builtin = pcall(require, "lint.linters." .. module)
			if not ok then
				vim.schedule(function()
					vim.notify(string.format("nvim-lint: builtin '%s' not found", module), vim.log.levels.WARN)
				end)
				return nil
			end

			local function with_nix(def)
				local linter = vim.deepcopy(def)
				linter.cmd = "nix"

				local target = spec.package or module
				local args = { "run", "--impure", "nixpkgs#" .. target, "--" }
				if spec.extra_args then
					vim.list_extend(args, spec.extra_args)
				end
				if type(linter.args) == "table" then
					vim.list_extend(args, linter.args)
				end
				linter.args = args

				return linter
			end

			if type(builtin) == "function" then
				return function(...)
					local def = builtin(...)
					if type(def) ~= "table" then
						return def
					end
					return with_nix(def)
				end
			end

			return with_nix(builtin)
		end

		local linter_specs = {
			clippy = { package = "cargo" },
			deadnix = {},
			eslint = {},
			fish = {},
			golangcilint = { package = "golangci-lint" },
			hadolint = {},
			htmlhint = {},
			jsonlint = { package = "nodePackages.jsonlint" },
			luacheck = { package = "lua54Packages.luacheck" },
			markdownlint = { package = "markdownlint-cli" },
			pylint = {},
			shellcheck = {},
			statix = {},
			stylelint = {},
			tflint = {},
			yamllint = {},
		}

		for name, spec in pairs(linter_specs) do
			local linter = wrap_with_nix(name, spec)
			if linter then
				lint.linters[name] = linter
			end
		end

		lint.linters_by_ft = {
			["markdown.mdx"] = { "markdownlint" },
			bash = { "shellcheck" },
			css = { "stylelint" },
			dockerfile = { "hadolint" },
			fish = { "fish" },
			go = { "golangcilint" },
			handlebars = { "htmlhint" },
			html = { "htmlhint" },
			javascript = { "eslint" },
			javascriptreact = { "eslint" },
			json = { "jsonlint" },
			json5 = { "jsonlint" },
			jsonc = { "jsonlint" },
			less = { "stylelint" },
			lua = { "luacheck" },
			markdown = { "markdownlint" },
			nix = { "deadnix", "statix" },
			python = { "pylint" },
			rust = { "clippy" },
			scss = { "stylelint" },
			sh = { "shellcheck" },
			terraform = { "tflint" },
			typescript = { "eslint" },
			typescriptreact = { "eslint" },
			vue = { "eslint" },
			yaml = { "yamllint" },
			zsh = { "shellcheck" },
		}

		local group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

		local function lint_buffer(bufnr)
			local ft = vim.bo[bufnr].filetype
			local names = lint.linters_by_ft[ft]
			if not names or vim.tbl_isempty(names) then
				return
			end
			lint.try_lint(names, { bufnr = bufnr })
		end

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = group,
			callback = function(event)
				lint_buffer(event.buf)
			end,
		})

		vim.keymap.set("n", "<leader>cl", function()
			lint_buffer(vim.api.nvim_get_current_buf())
		end, { desc = "Lint current buffer", silent = true })
	end,
}
