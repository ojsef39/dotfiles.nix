-- Custom tabline with file icons and modified indicators

local M = {}

vim.o.showtabline = 1
vim.o.tabline = "%!v:lua.require('ui-tabline').render()"

local function get_file_icon(filename, is_current)
  if filename == "[No Name]" then
    return "󰎛 "
  end

  -- Try to get icon from Mini.icons
  local ok, mini_icons = pcall(require, "mini.icons")
  if ok then
    local icon, hl = mini_icons.get("file", filename)
    if icon then
      return " %#" .. hl .. "#" .. icon .. (is_current and " %#TabLineSel#" or " %#TabLine#")
    end
  end

  return "󰈙 " .. (is_current and " %#TabLineSel#" or " %#TabLine#")
end

local function get_modified_indicator(bufnr)
  if vim.fn.getbufvar(bufnr, "&modified") == 1 then
    return " ●"
  end
  return ""
end

function M.render()
  local current = vim.fn.tabpagenr()
  local total = vim.fn.tabpagenr("$")
  local out = {}

  for tab = 1, total do
    local is_current = tab == current

    local names = {}

    for _, buf in ipairs(vim.fn.tabpagebuflist(tab)) do
      if vim.fn.buflisted(buf) == 1 then
        local n = vim.fn.bufname(buf)
        if n == "" then
          n = "[No Name]"
        end
        local filename = vim.fn.fnamemodify(n, ":t")
        local file_icon = get_file_icon(filename, is_current)
        local mod_indicator = get_modified_indicator(buf)

        table.insert(names, file_icon .. filename .. mod_indicator)
      end
    end
    local tab_content = table.concat(names, " ")
    local max_width = 60
    if #tab_content > max_width then
      tab_content = tab_content:sub(1, max_width - 3) .. "..."
    end

    table.insert(out, string.format("%s %s", tab_content, "%#TabLineFill#"))
  end

  return "%#TabLineFill#" .. table.concat(out, "") .. "%#TabLineFill#"
end

-- Register module in package.loaded so it can be required as 'ui-tabline'
package.loaded['ui-tabline'] = M

return M
