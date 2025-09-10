local M = {}

-- Configuration
local CONFIG = {
	pack_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt",
	plugin_config_dir = vim.fn.stdpath("config") .. "/lua/plugins",
	patterns = {
		name = "name%s*=%s*[\"']([^\"']+)[\"']",
		src = "src%s*=%s*[\"']([^\"']+/[^\"']+)[\"']",
	},
	symbols = { loaded = "●", deleted = "●", orphaned = "●", unloaded = "●" },
	colors = { loaded = "String", deleted = "ErrorMsg", orphaned = "WarningMsg", unloaded = "Comment" },
}

-- Utility functions
local function read_file_content(path)
	return vim.fn.filereadable(path) == 1 and table.concat(vim.fn.readfile(path), "\n") or ""
end

local function get_directory_entries(dir, filter_fn)
	if vim.fn.isdirectory(dir) ~= 1 then
		return {}
	end
	local entries = vim.fn.glob(dir .. "/*", false, true)
	return filter_fn and vim.tbl_filter(filter_fn, entries) or entries
end

local function extract_plugin_name(path)
	return vim.fn.fnamemodify(path, ":t"):gsub("%.git$", "")
end

-- Core data collection
local function get_configured_plugins()
	local configured = {}
	local config_files = get_directory_entries(CONFIG.plugin_config_dir, function(f)
		return f:match("%.lua$")
	end)

	for _, file in ipairs(config_files) do
		local content = read_file_content(file)

		-- Extract from name patterns
		for name in content:gmatch(CONFIG.patterns.name) do
			configured[name] = true
		end

		-- Extract from src patterns
		for src in content:gmatch(CONFIG.patterns.src) do
			local name = extract_plugin_name(src)
			if name then
				configured[name] = true
			end
		end
	end

	return configured
end

local function get_disk_plugins()
	local disk_plugins = {}
	local plugin_dirs = get_directory_entries(CONFIG.pack_dir, function(path)
		local name = extract_plugin_name(path)
		return vim.fn.isdirectory(path) == 1 and name ~= "after" and not name:match("^%.")
	end)

	for _, path in ipairs(plugin_dirs) do
		local name = extract_plugin_name(path)
		disk_plugins[name] = {
			name = name,
			path = path,
			is_loaded = false,
			is_configured = false,
		}
	end

	return disk_plugins
end

local function merge_plugin_data()
	local disk_plugins = get_disk_plugins()
	local configured = get_configured_plugins()
	local loaded_paths = vim.api.nvim_list_runtime_paths()
	local pack_dir_pattern = CONFIG.pack_dir:gsub("%-", "%%-")

	-- Mark configured plugins
	for name in pairs(configured) do
		if disk_plugins[name] then
			disk_plugins[name].is_configured = true
		end
	end

	-- Mark loaded plugins
	for _, path in ipairs(loaded_paths) do
		if path:match(pack_dir_pattern) then
			local name = extract_plugin_name(path)
			if disk_plugins[name] then
				disk_plugins[name].is_loaded = true
				disk_plugins[name].path = path
			end
		end
	end

	return vim.tbl_values(disk_plugins)
end

-- UI helpers
local function get_plugin_status(plugin, deleted_plugins)
	if deleted_plugins[plugin.name] then
		return "deleted"
	end
	if not plugin.is_configured then
		return "orphaned"
	end
	if not plugin.is_loaded then
		return "unloaded"
	end
	return "loaded"
end

local function create_display_lines(plugins, deleted_plugins)
	local width = math.min(80, math.floor(vim.o.columns * 0.9))
	local header = "📦 Loaded Plugins"
	local help = "[u]pdate [U]pdate all [d]elete [r]eload [q]uit"
	local total = string.format("Total: %d plugins", #plugins)

	local lines = {
		string.format("%s%s", string.rep(" ", math.floor((width - #header) / 2)), header),
		string.format("%s%s", string.rep(" ", math.floor((width - #help) / 2)), help),
		"",
	}

	local plugin_line_map = {}

	for i, plugin in ipairs(plugins) do
		local status = get_plugin_status(plugin, deleted_plugins)
		local symbol = CONFIG.symbols[status]
		local line = string.format("  %s %s", symbol, plugin.name)
		table.insert(lines, line)
		plugin_line_map[#lines] = i
	end

	table.insert(lines, string.format("%s%s", string.rep(" ", math.floor((width - #total) / 2)), total))

	return lines, plugin_line_map, width
end

local function apply_highlighting(buf, plugins, deleted_plugins)
	local ns = vim.api.nvim_create_namespace("pack_info")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	-- Header highlighting
	vim.api.nvim_buf_add_highlight(buf, ns, "Title", 0, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "Comment", 1, 0, -1)

	-- Plugin highlighting
	for i, plugin in ipairs(plugins) do
		local line_idx = i + 2
		local status = get_plugin_status(plugin, deleted_plugins)
		local color = CONFIG.colors[status]
		vim.api.nvim_buf_add_highlight(buf, ns, color, line_idx, 2, 3)
		vim.api.nvim_buf_add_highlight(buf, ns, "Normal", line_idx, 4, -1)
	end

	-- Total highlighting
	local total_line = #plugins + 3
	vim.api.nvim_buf_add_highlight(buf, ns, "MoreMsg", total_line, 0, -1)
end

-- Plugin operations
local function is_pack_plugin(plugin_name)
	return vim.tbl_contains(
		vim.tbl_map(function(p)
			return p.spec.name
		end, vim.pack.get()),
		plugin_name
	)
end

local function delete_plugin(plugin, deleted_plugins, refresh_fn)
	vim.ui.input({ prompt = "Delete " .. plugin.name .. "? (yes/no): " }, function(input)
		if input ~= "yes" then
			return
		end

		if is_pack_plugin(plugin.name) then
			vim.pack.del({ plugin.name })
			deleted_plugins[plugin.name] = true
			vim.notify(plugin.name .. " deleted successfully!", vim.log.levels.INFO)
			vim.schedule(refresh_fn)
		else
			vim.system({ "rm", "-rf", plugin.path }, {}, function(result)
				vim.schedule(function()
					if result.code == 0 then
						deleted_plugins[plugin.name] = true
						vim.notify(plugin.name .. " deleted successfully!", vim.log.levels.INFO)
						refresh_fn()
					else
						vim.notify("Failed to delete " .. plugin.name, vim.log.levels.ERROR)
					end
				end)
			end)
		end
	end)
end

-- Main function
function M.show()
	local plugins = merge_plugin_data()
	if #plugins == 0 then
		vim.notify("No plugins found", vim.log.levels.WARN)
		return
	end

	table.sort(plugins, function(a, b)
		return a.name:lower() < b.name:lower()
	end)

	local deleted_plugins = {}
	local lines, plugin_line_map, width = create_display_lines(plugins, deleted_plugins)

	-- Create buffer and window
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "packinfo"
	vim.bo[buf].modifiable = false
	vim.bo[buf].readonly = true

	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.85))
	local win = vim.api.nvim_open_win(buf, true, {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
	})

	apply_highlighting(buf, plugins, deleted_plugins)

	-- Refresh function
	local function refresh_display()
		vim.bo[buf].modifiable = true
		vim.bo[buf].readonly = false

		local new_lines, new_plugin_line_map = create_display_lines(plugins, deleted_plugins)
		plugin_line_map = new_plugin_line_map

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
		apply_highlighting(buf, plugins, deleted_plugins)

		vim.bo[buf].modifiable = false
		vim.bo[buf].readonly = true
	end

	local function get_current_plugin()
		local cursor_line = vim.fn.line(".")
		local plugin_idx = plugin_line_map[cursor_line]
		return plugin_idx and plugins[plugin_idx] or nil
	end

	-- Key mappings
	local keymaps = {
		{ "n", { "q", "<Esc>" }, ":close<CR>", { noremap = true, silent = true } },
		{
			"n",
			"u",
			function()
				local plugin = get_current_plugin()
				if plugin then
					vim.notify("Updating " .. plugin.name .. "...", vim.log.levels.INFO)
					vim.pack.update({ plugin.name })
				else
					vim.notify("No plugin selected", vim.log.levels.WARN)
				end
			end,
		},
		{ "n", "U", vim.pack.update },
		{
			"n",
			"d",
			function()
				local plugin = get_current_plugin()
				if plugin then
					delete_plugin(plugin, deleted_plugins, refresh_display)
				else
					vim.notify("No plugin selected", vim.log.levels.WARN)
				end
			end,
		},
		{
			"n",
			"r",
			function()
				vim.notify("Reloading plugins...", vim.log.levels.INFO)
				vim.api.nvim_win_close(win, true)
				vim.schedule(function()
					M.show()
				end)
			end,
		},
	}

	for _, map in ipairs(keymaps) do
		local mode, keys, action, opts = unpack(map)
		if type(keys) == "table" then
			for _, key in ipairs(keys) do
				vim.api.nvim_buf_set_keymap(
					buf,
					mode,
					key,
					type(action) == "string" and action or "",
					vim.tbl_extend("force", opts or {}, type(action) == "function" and { callback = action } or {})
				)
			end
		else
			vim.api.nvim_buf_set_keymap(
				buf,
				mode,
				keys,
				type(action) == "string" and action or "",
				vim.tbl_extend("force", opts or {}, type(action) == "function" and { callback = action } or {})
			)
		end
	end

	-- Window options
	local win_opts = { cursorline = true, number = false, relativenumber = false, wrap = false }
	for opt, value in pairs(win_opts) do
		vim.wo[win][opt] = value
	end
end

return M

