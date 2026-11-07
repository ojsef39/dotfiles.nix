-- A universal and reusable picker (from frostplexx/dotfiles.nix).
-- It uses a rex floating pane + fzf

local terminal = "com.superlogical.terminal"

-- sh -c takes the script, then $0 and the positional args "$@" expands to, so
-- prompt, paths and items reach the script without any shell quoting.
local fzf_pipeline = 'printf \'%s\\n\' "$@" | fzf --prompt="$prompt" --no-height --color=bg:-1 > "$out"'


local function read_first_line(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local line = file:read("*l")
    file:close()
    return line
end


local function find_rex_executable()
    -- The pane runs the caller's shell environment, which needn't have rex on its
    -- PATH. The CLI and the server are one binary, so ask the server for its own.
    local status = rex.call("server.status")
    if not status or not status.pid then
        return nil
    end

    local result = rex.exec({ "/bin/ps", "-o", "comm=", "-p", tostring(status.pid) })
    if not result or not result.ok then
        return nil
    end

    return result.stdout:gsub("%s+$", "")
end


-- The configuration file cannot wait for a selection: blocking its Lua state stops
-- Rex.app from taking input, and it receives no events. So its pane hands the
-- result back with client.action, which runs the action below with a client in
-- scope, and the action calls the on_select the caller registered.
local picker_callbacks = {}
local picker_counter = 0


rex.action({
    name = "picker_deliver_selection",
    title = "Picker: deliver selection",
    args = { picker_id = "string", selection_path = "string?" },
    run = function(_, args)
        local on_select = picker_callbacks[args.picker_id]
        if not on_select then
            return
        end
        picker_callbacks[args.picker_id] = nil

        local selection = read_first_line(args.selection_path)
        os.remove(args.selection_path)

        if selection and selection ~= "" then
            on_select(selection)
        end
    end,
})


local function build_callback_command(prompt, items, selection_path, rex_path, payload)
    local script = 'prompt=$1; out=$2; rex=$3; payload=$4; shift 4; ' .. fzf_pipeline
        .. '; exec "$rex" api call client.action "$payload"'
    local command = { "/bin/sh", "-c", script, "sh", prompt, selection_path, rex_path, payload }
    for _, item in ipairs(items) do
        table.insert(command, item)
    end
    return command
end


local function build_waiting_command(prompt, items, selection_path, done_path)
    -- The trap fires even when the pane is closed, so the wait always ends.
    local script = 'prompt=$1; out=$2; done=$3; trap \'echo > "$done"\' EXIT TERM INT HUP; shift 3; ' .. fzf_pipeline
    local command = { "/bin/sh", "-c", script, "sh", prompt, selection_path, done_path }
    for _, item in ipairs(items) do
        table.insert(command, item)
    end
    return command
end


local function build_payload(picker_id, selection_path)
    return string.format(
        '{"action":"picker_deliver_selection","args":{"picker_id":"%s","selection_path":"%s"}}',
        picker_id, selection_path)
end


local function resolve_position(position, width, padding)
    -- Where the new floating layer sits, as [x, y, w, h] fractions of the window's
    -- width and height. It must fit inside the window.
    padding = padding or 0
    local available = 1 - 2 * padding
    width = width or available

    if padding < 0 or padding >= 0.5 then
        error("Invalid padding: " .. tostring(padding) .. " (must be in [0, 0.5))")
    end

    if width <= 0 or width > available then
        error("Invalid width: " .. tostring(width) .. " (must be in (0, " .. available .. "])")
    end

    if position == "center" then
        return { padding + (available - width) / 2, padding, width, available }
    elseif position == "top" then
        return { padding + (available - width) / 2, padding, width, available / 2 }
    elseif position == "bottom" then
        return { padding + (available - width) / 2, padding + available / 2, width, available / 2 }
    elseif position == "left" then
        return { padding, padding, width, available }
    elseif position == "right" then
        return { 1 - padding - width, padding, width, available }
    end

    error("Invalid position: " .. position)
end


-- The floating layer in the active window that holds a block labeled `label`
local function open_picker_layer(label)
    local view = rex.session.view({})
    for _, window in ipairs(view and view.windows or {}) do
        if window.window_id == view.active_window_id then
            for _, layer in ipairs(window.layers or {}) do
                if layer.kind == "floating" then
                    for _, block in ipairs(layer.blocks or {}) do
                        if block.label == label then
                            return layer
                        end
                    end
                end
            end
        end
    end
end


function picker(opts)
    local opts = opts or {}
    local prompt = opts.prompt or "Select an option: "
    local items = opts.items or {}
    local on_select = opts.on_select or function(item) print("Selected: " .. item) end
    local position = opts.position or "center" -- one of "center", "top", "bottom", "left", "right"
    local width = opts.width or nil -- fraction of the window width, e.g. 0.5 for 50%
    local padding = opts.padding or 0 -- fraction of the window size inset from every edge
    local label = opts.label or "picker"

    -- Toggle like the other floats: a second press closes the open picker
    -- (its pending selection callback is simply never called).
    local open_layer = open_picker_layer(label)
    if open_layer then
        rex.session.close_layer({ layer_id = open_layer.layer_id })
        return
    end

    -- rex.wait and rex.sleep only exist in scripts run with "rex do".
    local is_script = rex.wait ~= nil
    local selection_path = os.tmpname()
    local done_path = selection_path .. ".done"
    local command

    if is_script then
        command = build_waiting_command(prompt, items, selection_path, done_path)
    else
        picker_counter = picker_counter + 1
        local picker_id = tostring(os.time()) .. "-" .. tostring(picker_counter)
        local rex_path = find_rex_executable()
        if not rex_path then
            os.remove(selection_path)
            error("picker: cannot find the rex executable to hand the selection back with")
        end
        picker_callbacks[picker_id] = on_select
        command = build_callback_command(
            prompt, items, selection_path, rex_path, build_payload(picker_id, selection_path))
    end

    local result, err = rex.session.new_layer({
        bounds = resolve_position(position, width, padding),
        layout = rex.layout.block({
            flavor = terminal .. ".shell",
            label = label,
            options = {
                command = command,
                exit = { on_completion = true, quick_exit_threshold_ms = 0 },
            },
        }),
        focus = true,
    })

    if err then
        os.remove(selection_path)
        error(err)
    end

    if not is_script then
        return
    end

    local wait_script = 'while [ ! -f "$1" ]; do /bin/sleep 0.1; done'
    rex.exec({ "/bin/sh", "-c", wait_script, "sh", done_path }, { timeout = 3600 })
    os.remove(done_path)

    local selection = read_first_line(selection_path)
    os.remove(selection_path)

    rex.session.close_layer({ layer_id = result.layer_id })

    if selection and selection ~= "" then
        on_select(selection)
    end
end
