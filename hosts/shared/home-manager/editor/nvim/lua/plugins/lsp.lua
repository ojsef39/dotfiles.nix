-- Function to load YAML-LS settings from .yaml-ls.json
local function load_yaml_ls_settings()
  local root = vim.fs.dirname(
    vim.fs.find({ ".git", "src", "docker-compose.yml", "docker-compose.yaml" }, { upward = true })[1]
  ) or vim.fn.getcwd()
  local path = root .. "/.yaml-ls.json"

  if vim.fn.filereadable(path) == 1 then
    local ok, content = pcall(vim.fn.readfile, path)
    if ok then
      local json_str = table.concat(content, "\n")
      local success, json = pcall(vim.json.decode, json_str)
      if success and json then
        return json
      end
    end
  end
  return {}
end

return {
  {
    "towolf/vim-helm",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        helm_ls = {
          settings = {
            ["helm-ls"] = {
              yamlls = {
                path = "yaml-language-server",
              },
            },
          },
        },
        yamlls = {
          settings = vim.tbl_deep_extend("force", {
            -- global YAML settings here
            yaml = {
              validate = true,
              hover = true,
              completion = true,
              format = {
                enable = true,
              },
              --   -- other global settings below
            },
          }, load_yaml_ls_settings()),
        },
      },
    },
  },
}
