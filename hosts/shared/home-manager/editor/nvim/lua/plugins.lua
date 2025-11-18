local M = {}

--- Load all plugin files from the plugins directory
--- Each plugin file is required in alphabetical order
M.load = function()
	local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"
	local plugin_files = vim.fn.glob(plugins_dir .. "/*.lua", false, true)

	-- Sort files alphabetically for consistent loading order
	table.sort(plugin_files)

	for _, file in ipairs(plugin_files) do
		-- Extract the plugin name from the file path
		local plugin_name = vim.fn.fnamemodify(file, ":t:r")

		-- Require the plugin module
		local ok, err = pcall(require, "plugins." .. plugin_name)
		if not ok then
			vim.notify(string.format("Failed to load plugin '%s': %s", plugin_name, err), vim.log.levels.ERROR)
		end
	end
end

return M
