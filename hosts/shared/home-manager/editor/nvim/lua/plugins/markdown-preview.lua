return {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    ft = { "markdown", "rst" },
    build = ":call mkdp#util#install()",
    config = function()
        vim.g.mkdp_filetypes = { "markdown", "rst" }
    end,
    keys = {
        {
            "<leader>mm",
            "<cmd>MarkdownPreviewToggle<CR>",
            desc = "Toggle preview",
            mode = { "n", "v" },
        },
        {
            "<leader>mp",
            "<cmd>MarkdownPreview<CR>",
            desc = "Start preview",
            mode = { "n", "v" },
        },
        {
            "<leader>ms",
            "<cmd>MarkdownPreviewStop<CR>",
            desc = "Stop preview",
            mode = { "n", "v" },
        },
    },
}
