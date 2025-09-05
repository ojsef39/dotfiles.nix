return {
    "shortcuts/no-neck-pain.nvim",
    lazy = false,
    keys = {
        { "<leader>cn", "<cmd>NoNeckPain<cr>", desc = "Toggle No Neck Pain" },
    },
    opts = {
        autocmds = {
            enableOnVimEnter = false,
        },
        width = 150,
        mappings = {
            enabled = false,
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
                location = nil,
                -- location = "~/Documents/vim-mds/",
            },
            bo = {
                filetype = "md",
            },
        },
    },
}
