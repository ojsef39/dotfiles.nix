-- LSP handlers and diagnostic configuration

-- Ignore workspace/diagnostic/refresh requests from servers that don't support it
vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
  return vim.NIL
end

-- Enable inlay hints globally
vim.lsp.inlay_hint.enable(true)

-- Diagnostic configuration
vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = tools.ui.diagnostics.ERROR,
      [vim.diagnostic.severity.HINT] = tools.ui.diagnostics.HINT,
      [vim.diagnostic.severity.INFO] = tools.ui.diagnostics.INFO,
      [vim.diagnostic.severity.WARN] = tools.ui.diagnostics.WARN,
    },
  },
  virtual_text = {
    prefix = "",
    spacing = 2,
    source = "if_many",
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
  float = {
    source = "if_many",
    prefix = function(diag)
      local level = vim.diagnostic.severity[diag.severity]
      local prefix = string.format("%s ", tools.ui.diagnostics[level])
      return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
    end,
  },
})
