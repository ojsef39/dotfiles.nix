local has_nerd_font = vim.g.have_nerd_font ~= false

local function get_tools()
	local tools = {}

	-- LSP
	local lsp_names = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.name ~= "null-ls" and client.name ~= "copilot" then
			table.insert(lsp_names, client.name)
		end
	end
	if #lsp_names > 0 then
		table.insert(tools, (has_nerd_font and "" or "LSP:") .. " " .. table.concat(lsp_names, ","))
	end

	-- Formatters
	local ok, conform = pcall(require, "conform")
	if ok then
		local formatters = conform.list_formatters and conform.list_formatters() or {}
		local fmt_names = {}
		for _, f in ipairs(formatters) do
			table.insert(fmt_names, type(f) == "table" and f.name or f)
		end
		if #fmt_names > 0 then
			table.insert(tools, (has_nerd_font and "" or "FMT:") .. " " .. table.concat(fmt_names, ","))
		end
	end

	-- Linters
	local ok, lint = pcall(require, "lint")
	if ok then
		local ft = vim.bo.filetype
		local linters = lint.linters_by_ft[ft] or {}

		-- Add actionlint for GitHub Actions workflow files
		if ft == "yaml" then
			local filepath = vim.api.nvim_buf_get_name(0)
			if filepath:match("%.github/workflows/.*%.ya?ml$") then
				linters = vim.deepcopy(linters)
				table.insert(linters, "actionlint")
			end
		end

		if #linters > 0 then
			table.insert(tools, (has_nerd_font and "" or "LINT:") .. " " .. table.concat(linters, ","))
		end
	end

	return #tools > 0 and "[" .. table.concat(tools, " ") .. "]" or nil
end

-- Custom location function showing only line and percentage
local function simple_location()
	local line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local percentage = math.floor((line / total_lines) * 100)
	return string.format(" %d:%d%%", line, percentage)
end

local function get_filetype_with_icon()
	local filetype = vim.bo.filetype
	if filetype == "" then
		return ""
	end

	-- Get icon from mini.icons
	local icon = ""
	local has_mini_icons, mini_icons = pcall(require, "mini.icons")
	if has_mini_icons then
		local file_icon = mini_icons.get("filetype", filetype)
		if file_icon then
			icon = file_icon .. " "
		end
	end

	return "" .. icon .. filetype
end

-- Custom diagnostics function using mini.icons
local function get_diagnostics_with_icons()
	local counts = vim.diagnostic.count(0)
	if vim.tbl_isempty(counts) then
		return ""
	end

	local parts = {}

	-- Error
	if counts[vim.diagnostic.severity.ERROR] then
		table.insert(parts, tools.ui.diagnostics.ERROR .. " " .. counts[vim.diagnostic.severity.ERROR])
	end

	-- Warning
	if counts[vim.diagnostic.severity.WARN] then
		table.insert(parts, tools.ui.diagnostics.WARN .. " " .. counts[vim.diagnostic.severity.WARN])
	end

	-- Info
	if counts[vim.diagnostic.severity.INFO] then
		table.insert(parts, tools.ui.diagnostics.INFO .. " " .. counts[vim.diagnostic.severity.INFO])
	end

	-- Hint
	if counts[vim.diagnostic.severity.HINT] then
		table.insert(parts, tools.ui.diagnostics.HINT .. " " .. counts[vim.diagnostic.severity.HINT])
	end

	return table.concat(parts, " ")
end

-- Custom content function for cleaner statusline
local function statusline_content()
	local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 999999999 })
	local git = MiniStatusline.section_git({ trunc_width = 75 })
	local diagnostics = get_diagnostics_with_icons()
	local location = simple_location()
	local tooling = get_tools()
	local filetype = get_filetype_with_icon()
	local fileinfo_strings = {}
	if tooling then
		table.insert(fileinfo_strings, tooling)
	end
	if filetype ~= "" then
		table.insert(fileinfo_strings, filetype)
	end
	if vim.tbl_isempty(fileinfo_strings) then
		table.insert(fileinfo_strings, "")
	end

	-- Get breadcrumbs from navic if available
	local breadcrumbs = ""
	local has_navic, navic = pcall(require, "nvim-navic")
	if has_navic and navic.is_available() then
		local navic_location = navic.get_location()
		if navic_location ~= "" then
			-- Calculate available space more conservatively
			local win_width = vim.api.nvim_win_get_width(0)
			local max_width = math.floor(win_width * 0.6) -- More conservative

			if #navic_location > max_width then
				-- Split on separators and keep the most specific parts
				local parts = vim.split(navic_location, " › ")
				local result = ""
				local total_len = 3 -- for "..."

				-- Start from the end (most specific) and work backwards
				for i = #parts, 1, -1 do
					local part_len = #parts[i] + (i < #parts and 3 or 0) -- +3 for " › "
					if total_len + part_len <= max_width then
						if result == "" then
							result = parts[i]
						else
							result = parts[i] .. " › " .. result
						end
						total_len = total_len + part_len
					else
						break
					end
				end

				-- Add ellipsis if we truncated
				if total_len < #navic_location then
					result = "..." .. (result ~= "" and " › " .. result or "")
				end

				breadcrumbs = result
			else
				breadcrumbs = navic_location
			end
		end
	end

	return MiniStatusline.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
		"%<", -- Mark general truncate point
		{ hl = "MiniStatuslineFilename", strings = { breadcrumbs } },
		"%=", -- End left alignment
		{ hl = "MiniStatuslineFileinfo", strings = fileinfo_strings },
		{ hl = mode_hl, strings = { location } },
	})
end

-- Custom inactive statusline content
local function statusline_content_inactive()
	local filename = vim.fn.expand("%:t")
	if filename == "" then
		filename = "[No Name]"
	end

	return MiniStatusline.combine_groups({
		{ hl = "MiniStatuslineInactive", strings = { " " .. filename .. " " } },
	})
end

require("mini.statusline").setup({
	content = {
		active = statusline_content,
		inactive = statusline_content_inactive,
	},
	use_icons = vim.g.have_nerd_font or false,
	set_vim_settings = false, -- Keep your existing statusline settings
})

