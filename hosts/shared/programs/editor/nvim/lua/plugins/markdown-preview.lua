return {
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    ft = { "markdown", "rst" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_filetypes = { "markdown", "rst" }
    end,
  },
}
