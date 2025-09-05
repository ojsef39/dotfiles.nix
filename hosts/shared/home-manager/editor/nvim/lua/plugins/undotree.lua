return {
    "mbbill/undotree",
    keys = {
        { "<leader>cu", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
    },
    config = function()
        -- Undotree window layout
        vim.g.undotree_WindowLayout = 2

        -- Focus the undotree window when opened
        vim.g.undotree_SetFocusWhenToggle = 1

        -- Shorter timestamps
        vim.g.undotree_ShortIndicators = 1

        -- Relative timestamps
        vim.g.undotree_RelativeTimestamp = 1

        -- Show diff in a horizontal split below
        vim.g.undotree_DiffpanelHeight = 10
    end,
}

