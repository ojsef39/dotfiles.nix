-- FFF.nvim integration with mini.pick
---@class FFFItem
---@field name string
---@field path string
---@field relative_path string
---@field size number
---@field modified number
---@field total_frecency_score number
---@field modification_frecency_score number
---@field access_frecency_score number
---@field git_status string

---@class PickerItem
---@field text string
---@field path string
---@field score number

---@class FFFPickerState
---@field current_file_cache string
local state = {}

local ns_id = vim.api.nvim_create_namespace("MiniPick FFFiles Picker")

---@param query string|nil
---@return PickerItem[]
local function find(query)
  local file_picker = require("fff.file_picker")

  query = query or ""
  ---@type FFFItem[]
  local fff_result = file_picker.search_files(query, 100, 4, state.current_file_cache, false)

  local items = {}
  for _, fff_item in ipairs(fff_result) do
    local item = {
      text = fff_item.relative_path,
      path = fff_item.path,
      score = fff_item.total_frecency_score,
    }
    table.insert(items, item)
  end

  return items
end

---@param items PickerItem[]
local function show(buf_id, items)
  local icon_data = {}

  -- Show items
  local items_to_show = {}
  for i, item in ipairs(items) do
    local icon, hl, _ = MiniIcons.get("file", item.text)
    icon_data[i] = { icon = icon, hl = hl }

    items_to_show[i] = string.format("%s %s", icon, item.text)
  end
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, items_to_show)

  vim.api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)

  local icon_extmark_opts = { hl_mode = "combine", priority = 200 }
  for i, item in ipairs(items) do
    -- Highlight Icons
    icon_extmark_opts.hl_group = icon_data[i].hl
    icon_extmark_opts.end_row, icon_extmark_opts.end_col = i - 1, 1
    vim.api.nvim_buf_set_extmark(buf_id, ns_id, i - 1, 0, icon_extmark_opts)

    -- Highlight score
    local col = #items_to_show[i] - #tostring(item.score) - 3
    icon_extmark_opts.hl_group = "FFFileScore"
    icon_extmark_opts.end_row, icon_extmark_opts.end_col = i - 1, #items_to_show[i]
    vim.api.nvim_buf_set_extmark(buf_id, ns_id, i - 1, col, icon_extmark_opts)
  end
end

local function run()
  -- Setup fff.nvim
  local file_picker = require("fff.file_picker")
  if not file_picker.is_initialized() then
    local setup_success = file_picker.setup()
    if not setup_success then
      vim.notify("Could not setup fff.nvim", vim.log.levels.ERROR)
      return
    end
  end

  -- Cache current file to deprioritize in fff.nvim
  if not state.current_file_cache then
    local current_buf = vim.api.nvim_get_current_buf()
    if current_buf and vim.api.nvim_buf_is_valid(current_buf) then
      local current_file = vim.api.nvim_buf_get_name(current_buf)
      if current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
        local relative_path = vim.fs.relpath(current_file, vim.uv.cwd())
        state.current_file_cache = relative_path
      else
        state.current_file_cache = nil
      end
    end
  end

  -- Start picker
  MiniPick.start({
    source = {
      name = "FFFiles",
      items = find,
      match = function(_, _, query)
        local items = find(table.concat(query))
        MiniPick.set_picker_items(items, { do_match = false })
      end,
      show = show,
    },
  })

  state.current_file_cache = nil -- Reset cache
end

MiniPick.registry.fffiles = run

-- Override vim.ui.select with mini.pick
vim.ui.select = MiniPick.ui_select
