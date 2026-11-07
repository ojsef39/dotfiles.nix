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


local focus = require("utils/focus")


-- When a float closes, Rex moves focus to whatever pane is nearest, not the one
-- the float was opened from. Remember that pane per float label.
local return_to = {}

local function focus_block(block_id)
    if block_id then
        rex.session.focus_block({ block_id = block_id }) -- the pane may be gone; ignore
    end
end


-- Run a program through an interactive fish so it gets the env from
-- interactiveShellInit (EDITOR=nvim etc.); SKIP_FF=1 skips fastfetch, like kitty did.
-- With job control on, the program gets its own foreground process group, so
-- Rex sees it as the pane's foreground process (smart_splits passes ctrl+h/j/k/l
-- through to lazygit only then), and fish still runs afterwards to focus the
-- pane the float was opened from again once the program quits.
local function in_fish(program, return_block)
    local script = "status job-control full; " .. program
    if return_block then
        script = script .. string.format(
            '; "$REX_BIN_DIR/rex" api call session.focus_block "{\\"session_id\\":\\"$REX_SESSION\\",\\"block_id\\":\\"%s\\"}" >/dev/null 2>&1',
            return_block)
    end
    return { "/usr/bin/env", "SKIP_FF=1", "fish", "-i", "-c", script }
end


-- `program` is a fish command line, or nil for a plain shell
local function open_float(ctx, program, label)
    local origin = focus.focused_block_id(ctx)
    return_to[label] = origin
    local _, err = rex.session.new_layer({
        bounds = bounds,
        layout = rex.layout.block({
            flavor = terminal .. ".shell",
            label = label,
            options = { command = program and in_fish(program, origin) or nil, cwd = focused_cwd(ctx) },
        }),
        focus = true,
    })
    if err then
        error(err)
    end
end


local function close_float(label)
    local view, err = rex.session.view({})
    if err then
        error(err)
    end

    local layer = focus.floating_layer_with_label(label, view)
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

    local layer = focus.floating_layer_with_label(label, view)
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
        if close_float("lazygit_float") then
            focus_block(return_to.lazygit_float)
        else
            open_float(ctx, "lazygit", "lazygit_float")
        end
    end,
})


-- Replaces kitty's ctrl+shift+m Yazi tab
rex.action({
    name = "yazi_float",
    title = "Yazi Terminal",
    keywords = "yazi files file manager float",
    run = function(ctx)
        if close_float("yazi_float") then
            focus_block(return_to.yazi_float)
        else
            open_float(ctx, "yazi", "yazi_float")
        end
    end,
})
