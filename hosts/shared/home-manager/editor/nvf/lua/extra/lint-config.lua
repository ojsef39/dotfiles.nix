-- nvim-lint setup

local lint = require("lint")

-- Lint function with actionlint logic
local function lint_buffer(bufnr)
  local ft = vim.bo[bufnr].filetype
  local names = lint.linters_by_ft[ft]
  if not names or vim.tbl_isempty(names) then
    return
  end

  -- Add actionlint for GitHub Actions workflow files
  if ft == "yaml" then
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    if filepath:match("%.github/workflows/.*%.ya?ml$") then
      names = vim.deepcopy(names)
      table.insert(names, "actionlint")
    end
  end

  lint.try_lint(names, { bufnr = bufnr })
end

-- Autocommands for linting
local lint_group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = lint_group,
  callback = function(event)
    lint_buffer(event.buf)
  end,
})

-- Expose lint_buffer globally
_G.lint_buffer = lint_buffer