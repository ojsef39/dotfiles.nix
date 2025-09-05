---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "lua-language-server", "--run", "lua-language-server"},
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    filetypes = { "lua" },
}
