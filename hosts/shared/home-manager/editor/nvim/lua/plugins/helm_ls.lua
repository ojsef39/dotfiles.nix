local lspconfig = require("lspconfig")

lspconfig.helm_ls.setup({
  settings = {
    ["helm-ls"] = {
      yamlls = {
        path = "yaml-language-server",
      },
    },
  },
})

return {
  {
    "towolf/vim-helm",
  },
}
