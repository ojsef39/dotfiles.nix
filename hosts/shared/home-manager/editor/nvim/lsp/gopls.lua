---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "gopls", "--run", "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = {
        "go.mod",
        "go.work",
        ".git",
        "src",
    },
}
