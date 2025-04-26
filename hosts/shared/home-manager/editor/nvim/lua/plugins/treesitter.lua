return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "go",
        "json",
        "query",
        "vim",
        "regex",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "yaml",
      })
    end,
  },
}
