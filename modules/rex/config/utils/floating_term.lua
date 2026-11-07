---@diagnostics disable: undefined-global, unused-local, unused-function
-- Toggleable floating panes (from frostplexx/dotfiles.nix)
local terminal = "com.superlogical.terminal"
local bounds = { 0.05, 0.05, 0.9, 0.9 }

local function focused_cwd(ctx)
    -- The shell reports its cwd as file://<cwd>, so we need to strip the file:// prefix
    local pwd = rex.block.call(terminal, "pwd", { block_id = ctx.block_id })
    if pwd and pwd.pwd then
        return (pwd.pwd:gsub("^file://[^/]*", ""))
    end

    -- If the pwd call fails, try to get the cwd from the foreground process
    local proc = rex.block.call(terminal, "process", { block_id = ctx.block_id })
    return proc and proc.foreground and proc.foreground.cwd or nil
end


-- Run a program through an interactive fish so it gets the env from
-- interactiveShellInit (EDITOR=nvim etc.); SKIP_FF=1 skips fastfetch, like kitty did.
local function in_fish(program)
    return { "/usr/bin/env", "SKIP_FF=1", "fish", "-i", "-c", program }
end


local function open_float(ctx, command, label)
    local _, err = rex.session.new_layer({
        bounds = bounds,
        layout = rex.layout.block({
            flavor = terminal .. ".shell",
            label = label,
            options = { command = command, cwd = focused_cwd(ctx) },
        }),
        focus = true,
    })
    if err then
        error(err)
    end
end


local function floating_block(view, label)
    for _, window in ipairs(view.windows or {}) do
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


local function close_float(label)
    local view, err = rex.session.view({})
    if err then
        error(err)
    end

    local layer = floating_block(view, label)
    if not layer then
        return false
    end
    local _, close_err = rex.session.close_layer({ layer_id = layer.layer_id })
    if close_err then
        error(close_err)
    end
    return true
end


local function toggle_float(ctx, command, label)
    local view, err = rex.session.view({})
    if err then
        error(err)
    end

    local layer = floating_block(view, label)
    if layer then
        local minimized = layer.state == "minimized"
        local _, set_err = rex.session.set_layer_state({
            layer_id = layer.layer_id,
            state = minimized and "normal" or "minimized",
            focus = minimized,
        })
        if set_err then
            error(set_err)
        end
        return
    end

    open_float(ctx, command, label)
end


rex.action({
    name = "floating_term",
    title = "Floating Terminal",
    keywords = "floating terminal float popup",
    run = function(ctx)
        toggle_float(ctx, nil, "floating_term")
    end,
})


rex.action({
    name = "lazygit_float",
    title = "Lazygit Terminal",
    keywords = "lazygit git float",
    run = function(ctx)
        if not close_float("lazygit_float") then
            open_float(ctx, in_fish("lazygit"), "lazygit_float")
        end
    end,
})


-- Replaces kitty's ctrl+shift+m Yazi tab
rex.action({
    name = "yazi_float",
    title = "Yazi Terminal",
    keywords = "yazi files file manager float",
    run = function(ctx)
        if not close_float("yazi_float") then
            open_float(ctx, in_fish("yazi"), "yazi_float")
        end
    end,
})
