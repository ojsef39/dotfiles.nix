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

-- custom tags for authentik yaml files
lspconfig.yamlls.setup({
  settings = {
    yaml = {
      customTags = {
        "!Condition sequence",
        "!Context scalar",
        "!Enumerate sequence",
        "!Env scalar",
        "!Find sequence",
        "!Format sequence",
        "!If sequence",
        "!Index scalar",
        "!KeyOf scalar",
        "!Value scalar",
        "!AtIndex scalar",
      },
    },
  },
})

return {
  {
    "towolf/vim-helm",
  },
}
