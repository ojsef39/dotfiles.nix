---@diagnostics disable: undefined-global, unused-local, unused-function
-- Project picker (frostplexx's sessionizer, fed like the old kitty
-- project_selector.sh): every git repo under the ghq root plus every
-- directory in ~/.config. Picking one opens a new session there.
local picker = require "utils/picker"

local home = os.getenv("HOME")
local ghq_root = home .. "/CodeProjects" -- vars.git.ghq
local extra_dirs = { home .. "/.config" } -- vars.kitty.project_selector


-- Paths are listed relative to $HOME
local function enumerate_projects()
    local projects = {}
    -- find exits non-zero on any unreadable subdir (e.g. a root-owned .cache),
    -- so keep whatever it printed and only log the error
    local result, err = rex.exec(
        { "/usr/bin/find", ghq_root, "-maxdepth", "5", "-type", "d", "-name", ".git", "-prune" })
    local repos = result and result.stdout or ""
    if not (result and result.ok) then
        rex.log("warn", "sessionizer: could not list repos in " .. ghq_root .. ": "
            .. tostring(err or (result and result.stderr)))
    end
    for line in repos:gmatch("[^\r\n]+") do
        table.insert(projects, (line:gsub("/%.git$", ""):gsub("^" .. home:gsub("%p", "%%%0") .. "/", "")))
    end
    for _, dir in ipairs(extra_dirs) do
        local sub = rex.exec({ "/usr/bin/find", dir, "-mindepth", "1", "-maxdepth", "1", "-type", "d" })
        for line in (sub and sub.stdout or ""):gmatch("[^\r\n]+") do
            table.insert(projects, (line:gsub("^" .. home:gsub("%p", "%%%0") .. "/", "")))
        end
    end
    table.sort(projects)
    return projects
end


local function app_client_id()
    local clients = rex.call("client.list")
    for _, client in ipairs(clients and clients.clients or {}) do
        if client.info and client.info.kind == "app" and client.connection_state == "connected" then
            return client.client_id
        end
    end
    return nil
end


rex.action({
    name = "session_new_project",
    title = "New Project Session",
    description = "Create a new session for a project",
    keywords = "project session",
    run = function()
        picker({
            prompt = "Jump to...",
            items = enumerate_projects(),
            on_select = function(item)
                local project_path = home .. "/" .. item
                -- Label with the last two path components, e.g. "ojsef39/dotfiles.nix"
                local label = item:match("([^/]+/[^/]+)$") or item
                local created, err = rex.call("session.create", {
                    label = " " .. label,
                    initial_windows = {
                        {
                            layout = rex.layout.block({
                                flavor = "com.superlogical.terminal.shell",
                                options = { cwd = project_path },
                            }),
                        },
                    },
                })
                if err then
                    error(err)
                end

                -- Shows the new session. Needs Remote Control turned on in Rex Settings;
                -- the session exists either way.
                local app_client = app_client_id()
                local _, select_err
                if app_client then
                    _, select_err = rex.call("client.perform", {
                        client_id = app_client,
                        action = "session.select",
                        args = { session_id = created.session_id },
                    })
                end
                if select_err then
                    -- The picker's callback runs as a CLI connection, so ask the app
                    -- directly. When Rex.app dispatched the action itself, queueing it
                    -- back is enough.
                    local queued, queue_err = pcall(rex.client.queue, "session.select", { session_id = created.session_id })
                    if not queued or queue_err then
                        rex.log("warn", "sessionizer: created session but could not show it: " .. tostring(queue_err))
                    end
                end
            end,
            label = "Project Picker",
            position = "bottom",
            width = 0.5,
            padding = 0.01,
        })
    end,
})
