return {
  "mikavilpas/yazi.nvim",
  lazy = true,
  keys = {
    {
      -- Open in the current working directory
      "<leader>ee",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
  },
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
    -- Set environment variables for Yazi
    env = {
      SKIP_FF = "1",
    },
  },
}
