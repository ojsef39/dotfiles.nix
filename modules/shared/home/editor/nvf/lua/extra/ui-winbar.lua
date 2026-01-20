-- Custom winbar with breadcrumb-style path display

local folder_icon = _G.tools.ui.kind_icons.Folder

-- Cache highlights setup
local highlights_setup = false
local function setup_highlights()
	if highlights_setup then
		return
	end
	local mocha = require("catppuccin.palettes").get_palette("macchiato")
	vim.api.nvim_set_hl(0, "WinbarSeparator", { fg = mocha.green, bold = true })
	vim.api.nvim_set_hl(0, "WinBarDir", { fg = mocha.mauve, italic = true })
	vim.api.nvim_set_hl(0, "Winbar", { fg = mocha.subtext0 })
	highlights_setup = true
end

local M = {}

-- Cache for expensive operations
local path_cache = {}
local cache_timer = vim.uv.new_timer()

--- Window bar that shows the current file path
---@return string
function M.render()
	setup_highlights()

	local bufnr = vim.api.nvim_get_current_buf()
	local cache_key = bufnr .. vim.b.changedtick

	if path_cache[cache_key] then
		return path_cache[cache_key]
	end

	local path = vim.fs.normalize(vim.fn.expand("%:p") --[[@as string]])

	-- No special styling for diff views
	if vim.startswith(path, "diffview") then
		local result = string.format("%%#Winbar#%s", path)
		path_cache[cache_key] = result
		return result
	end

	local separator = " %#WinbarSeparator# "
	local prefix, prefix_path = "", ""

	-- Shorten path if window is too narrow
	if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
		path = vim.fn.pathshorten(path)
	else
		-- Add prefix for special directories
		local special_dirs = {
			CODE = vim.g.projects_dir,
			NIX = vim.g.nix_dir,
			HOME = vim.env.HOME,
		}
		for dir_name, dir_path in pairs(special_dirs) do
			if dir_path and vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
				prefix, prefix_path = dir_name, dir_path
			end
		end
		if prefix ~= "" then
			path = path:gsub("^" .. vim.pesc(prefix_path), "")
			prefix = string.format("%%#WinBarDir#%s %s%s", folder_icon, prefix, separator)
		end
	end

	-- Remove leading slash
	path = path:gsub("^/", "")

	local result = table.concat({
		" ",
		prefix,
		table.concat(
			vim.iter(vim.split(path, "/"))
				:map(function(segment)
					return string.format("%%#Winbar#%s", segment)
				end)
				:totable(),
			separator
		),
	})

	-- Cache result and clear old cache periodically
	path_cache[cache_key] = result
	cache_timer:stop()
	cache_timer:start(5000, 0, function()
		path_cache = {}
	end)

	return result
end

-- Register module in package.loaded so it can be required as 'ui-winbar'
package.loaded["ui-winbar"] = M

-- Attach winbar to normal buffers
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("nvf/winbar", { clear = true }),
	desc = "Attach winbar",
	callback = function(args)
		if
			not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
			and vim.bo[args.buf].buftype == "" -- Normal buffer
			and vim.api.nvim_buf_get_name(args.buf) ~= "" -- Has a file name
			and not vim.wo[0].diff -- Not in diff mode
		then
			vim.wo.winbar = "%{%v:lua.require'ui-winbar'.render()%}"
		end
	end,
})

return M
