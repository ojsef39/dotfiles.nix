return {
  "shortcuts/no-neck-pain.nvim",
  opts = {
    autocmds = {
      enableOnVimEnter = true,
    },
    width = 150,
    mappings = {
      enabled = true,
    },
    buffers = {
      colors = {
        blend = -0.2,
        backgroundColor = "catppuccin-machiatto",
      },
      scratchPad = {
        -- set to `false` to
        -- disable auto-saving
        enabled = false,
        -- set to `nil` to default
        -- to current working directory
        location = "~/Documents/vim-mds/",
      },
      bo = {
        filetype = "md",
      },
    },
    integrations = {
      NeoTree = {
        position = "left",
        reopen = true,
      },
    },
  },
}
