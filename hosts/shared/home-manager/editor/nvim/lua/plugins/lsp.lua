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
              schemas = {
                ["https://goauthentik.io/blueprints/schema.json"] = "bp-*.yaml",
              },
            },
          },
        },
      },
    },
  },
}
