--- Custom mark API for showing marks in signcolumn
--- Originally written by MariaSolOs, modified for nvf

--- Map of mark information per buffer
---@type table<integer, table<string, {line: integer, id: integer}>>
local marks = {}
local Marks = {}

--- Keeps track of the signs already created
---@type table<string, boolean>
local sign_cache = {}

--- The sign and autocommand group name
local sign_group_name = "nvf/marks_signs"

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

  vim.fn.sign_unplace(sign_group_name, { buffer = bufnr, id = buffer_marks[mark].id })
  buffer_marks[mark] = nil

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
    delete_mark(mark, bufnr)
  end

  local id = mark:byte() * 100
  line = line or vim.api.nvim_win_get_cursor(0)[1]
  buffer_marks[mark] = { line = line, id = id }

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

-- Set key mappings
vim.api.nvim_set_keymap("n", "m", "", {
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

vim.api.nvim_set_keymap("n", "dm", "", {
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

vim.api.nvim_set_keymap("n", "dm-", "", {
  desc = "Delete all buffer marks",
  callback = function()
    local curbuf = vim.api.nvim_get_current_buf()
    marks[curbuf] = {}
    vim.fn.sign_unplace(sign_group_name, { buffer = curbuf })
    vim.cmd("delmarks!")
  end,
})

-- Handle BufWinEnter events to refresh marks in the signcolumn
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("nvf/marks", { clear = true }),
  desc = "Show marks in signcolumn",
  callback = function(args)
    local bufnr = args.buf
    if vim.bo[bufnr].bt ~= "" then
      return true
    end

    if not marks[bufnr] then
      marks[bufnr] = {}
    end

    -- Remove deleted marks
    for mark, _ in pairs(marks[bufnr]) do
      if vim.api.nvim_buf_get_mark(bufnr, mark)[1] == 0 then
        delete_mark(mark, bufnr)
      end
    end

    -- Register uppercase marks
    for _, data in ipairs(vim.fn.getmarklist()) do
      local mark = data.mark:sub(2, 3)
      local mark_buf, mark_line = unpack(data.pos)
      local cached_mark = marks[bufnr][mark]

      if mark_buf == bufnr and is_uppercase_mark(mark) and (not cached_mark or mark_line ~= cached_mark.line) then
        register_mark(mark, bufnr, mark_line)
      end
    end

    -- Register lowercase marks
    for _, data in ipairs(vim.fn.getmarklist("%")) do
      local mark = data.mark:sub(2, 3)
      local mark_line = data.pos[2]
      local cached_mark = marks[bufnr][mark]

      if is_lowercase_mark(mark) and (not cached_mark or mark_line ~= cached_mark.line) then
        register_mark(mark, bufnr, mark_line)
      end
    end
  end,
})

return Marks
