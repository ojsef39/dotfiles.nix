-- Conform formatexpr and toggle

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

_G.conform_enabled = true

local conform = require("conform")
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

-- Expose toggle function globally
_G.toggle_conform = toggle_conform