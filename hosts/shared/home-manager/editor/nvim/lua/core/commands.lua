local function LspInfo()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
        vim.notify("No LSP clients attached", vim.log.levels.WARN)
        return
    end

    local info = {}
    for _, client in pairs(clients) do
        local client_info = {
            "Client: " .. client.name,
            "ID: " .. client.id,
            "Root directory: " .. (client.config.root_dir or "Not set"),
            "Capabilities:",
        }

        -- Add key capabilities
        local caps = client.server_capabilities
        local capabilities = {
            "    • Completion: " .. tostring(caps.completionProvider ~= nil),
            "    • Hover: " .. tostring(caps.hoverProvider ~= nil),
            "    • Definition: " .. tostring(caps.definitionProvider ~= nil),
            "    • References: " .. tostring(caps.referencesProvider ~= nil),
            "    • Diagnostics: " .. tostring(caps.diagnosticProvider ~= nil),
        }

        for _, cap in ipairs(capabilities) do
            table.insert(client_info, cap)
        end

        table.insert(info, table.concat(client_info, "\n"))
    end

    vim.notify(table.concat(info, "\n\n"), vim.log.levels.INFO)
end

-- Register the command
vim.api.nvim_create_user_command("LspInfo", LspInfo, {})


vim.api.nvim_create_user_command('Todos', function()
    MiniPick.builtin.grep({ pattern = '(TODO|FIXME|HACK|NOTE):' })
end, { desc = 'Grep TODOs', nargs = 0 })

