---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "nodePackages.vscode-langservers-extracted", "--run", "vscode-html-language-server --stdio" },
    filetypes = { "html", "htm" },
    root_markers = {
        "package.json",
        ".git",
        "src",
    },
}
