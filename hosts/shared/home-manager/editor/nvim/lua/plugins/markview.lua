return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "OXY2DEV/markview.nvim" },
    priority = 49,
    lazy = false,
    opts = {
        preview = {
            icon_provider = "mini", -- "mini" or "devicons" or "internal"
        }
    }
}
