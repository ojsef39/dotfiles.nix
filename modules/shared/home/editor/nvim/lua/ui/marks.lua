--- Custom mark API.
--- Implementation slightly inspired by https://github.com/chentoast/marks.nvim, but this is
--- much simpler.

--- originally written by MariaSolOs
--- (https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/marks.lua)
--- (no longer available)
--- modified by me for my own neovim config (https://gitlab.com/silvercircle74/nvim):
---   * use global keymap (registered from keymap.lua)
---   * change sign group name
---   * integrated BufWinEnter funtionality in my own handler (auto.lua)
---   TODO: pluginify (really worth it? This is just so simple)
--- Map of mark information per buffer.
---@type table<integer, table<string, {line: integer, id: integer}>>
local marks = {}
local Marks = {}

--- Keeps track of the signs I've already created.
---@type table<string, boolean>
local sign_cache = {}

--- The sign and autocommand group name.
local sign_group_name = "alexvie/marks_signs"

---@param mark string
---@return boolean
local function is_lowercase_mark(mark)
	return 97 <= mark:byte() and mark:byte() <= 122
end

---@param mark string
---@return boolean
local function is_uppercase_mark(mark)
	return 65 <= mark:byte() and mark:byte() <= 90
end

---@param mark string
---@return boolean
local function is_letter_mark(mark)
	return is_lowercase_mark(mark) or is_uppercase_mark(mark)
end

---@param mark string
---@param bufnr integer
local function delete_mark(mark, bufnr)
	local buffer_marks = marks[bufnr]
	if not buffer_marks or not buffer_marks[mark] then
		return
	end

	-- Remove the sign.
	vim.fn.sign_unplace(sign_group_name, { buffer = bufnr, id = buffer_marks[mark].id })
	buffer_marks[mark] = nil

	-- Remove the mark.
	vim.cmd("delmarks " .. mark)
end

---@param mark string
---@param bufnr integer
---@param line? integer
local function register_mark(mark, bufnr, line)
	local buffer_marks = marks[bufnr]
	if not buffer_marks then
		return
	end

	if buffer_marks[mark] then
		-- Mark already exists, remove it first.
		delete_mark(mark, bufnr)
	end

	-- Add the sign to the tracking table.
	local id = mark:byte() * 100
	line = line or vim.api.nvim_win_get_cursor(0)[1]
	buffer_marks[mark] = { line = line, id = id }

	-- Create the sign.
	local sign_name = "Marks_" .. mark
	if not sign_cache[sign_name] then
		vim.fn.sign_define(sign_name, { text = mark, texthl = "DiagnosticSignOk" })
		sign_cache[sign_name] = true
	end
	vim.fn.sign_place(id, sign_group_name, sign_name, bufnr, {
		lnum = line,
		priority = 10,
	})
end

local skm = vim.api.nvim_set_keymap

-- set key mappings. this is called from keymap.lua globally
function Marks.set_keymaps()
	skm("n", "m", "", {
		desc = "Add mark",
		callback = function()
			local curbuf = vim.api.nvim_get_current_buf()
			local mark = vim.fn.getcharstr()
			if not is_letter_mark(mark) then
				return
			end
			register_mark(mark, curbuf)
			vim.cmd("normal! m" .. mark)
		end,
	})

	skm("n", "dm", "", {
		desc = "Delete mark",
		callback = function()
			local curbuf = vim.api.nvim_get_current_buf()
			local mark = vim.fn.getcharstr()
			if not is_letter_mark(mark) then
				return
			end
			delete_mark(mark, curbuf)
		end,
	})

	skm("n", "dm-", "", {
		desc = "Delete all buffer marks",
		callback = function()
			local curbuf = vim.api.nvim_get_current_buf()
			marks[curbuf] = {}
			vim.fn.sign_unplace(sign_group_name, { buffer = curbuf })
			vim.cmd("delmarks!")
		end,
	})
end

--- handle BufWinEnter events to refresh marks in the signcolumn
--- @param args table: event arguments
function Marks.BufWinEnterHandler(args)
	local bufnr = args.buf
	-- Only handle normal buffers.
	if vim.bo[bufnr].bt ~= "" then
		return true
	end

	if not marks[bufnr] then
		marks[bufnr] = {}
	end

	-- Remove all marks that were deleted.
	for mark, _ in pairs(marks[bufnr]) do
		if vim.api.nvim_buf_get_mark(bufnr, mark)[1] == 0 then
			delete_mark(mark, bufnr)
		end
	end

	-- Register the letter marks.
	for _, data in ipairs(vim.fn.getmarklist()) do
		local mark = data.mark:sub(2, 3)
		local mark_buf, mark_line = unpack(data.pos)
		local cached_mark = marks[bufnr][mark]

		if mark_buf == bufnr and is_uppercase_mark(mark) and (not cached_mark or mark_line ~= cached_mark.line) then
			register_mark(mark, bufnr, mark_line)
		end
	end
	for _, data in ipairs(vim.fn.getmarklist("%")) do
		local mark = data.mark:sub(2, 3)
		local mark_line = data.pos[2]
		local cached_mark = marks[bufnr][mark]

		if is_lowercase_mark(mark) and (not cached_mark or mark_line ~= cached_mark.line) then
			register_mark(mark, bufnr, mark_line)
		end
	end
end

return Marks
