return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "macchiato",         -- latte, frappe, macchiato, mocha
        transparent_background = true, -- disables setting the background color.
        float = {
            transparent = true,        -- enable transparent floating windows
            solid = false,             -- use solid styling for floating windows, see |winborder|
        },
        term_colors = true,
        auto_integrations = true,
    }
}
