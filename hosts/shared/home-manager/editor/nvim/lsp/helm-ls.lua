---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "helm-ls", "--run", "helm_ls serve" },
    filetypes = { "helm", "helmFile" },
    root_markers = {
        "Chart.yaml",
    },
    ['helm-ls'] = {
        yamlls = {
            path = "nix-shell -p nodePackages.yaml-language-server --run yaml-language-server --stdio"
        }
    }
}
