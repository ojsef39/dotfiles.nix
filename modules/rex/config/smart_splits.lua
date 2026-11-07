-- Neovim and Rex panes behave as one grid for smart-splits.nvim (based on
-- frostplexx/dotfiles.nix). When nvim is in the foreground the key is forwarded
-- to it, otherwise Rex moves focus / resizes itself.
local default_resize_amount = 3

local vim_programs = { "^n?vim" }
-- Programs that get ctrl+h/j/k/l themselves instead of Rex moving focus
-- (lazygit uses ctrl+j/k to move commits)
local focus_passthrough_programs = { "^n?vim", "^lazygit$" }

local focused_block_id = require("utils/focus").focused_block_id

-- Send `keyspec` ("ctrl+j", "alt+h": one modifier and one letter) straight to
-- `block_id`. pane.send_key through rex.client.queue does not reach a program
-- in a floating pane, so forwarding broke for the lazygit float.
local function send_key_to(ctx, block_id, keyspec)
    local mods, letter = keyspec:match("^(%a+)%+(%a)$")
    if not mods then
        error("smart_splits: cannot forward key " .. keyspec, 0)
    end
    for _, action in ipairs({ "press", "release" }) do
        local _, err = rex.call("block.event", {
            session_id = ctx.session_id,
            block_id = block_id,
            event = {
                type = "key",
                payload = {
                    key = "key_" .. letter,
                    mods = mods,
                    consumed_mods = "",
                    text = "",
                    unshifted_codepoint = string.byte(letter),
                    composing = false,
                    action = action,
                },
            },
        })
        if err ~= nil then
            error(err, 0)
        end
    end
end

local function foreground_matches(block_id, patterns)
    local process = rex.block.call("com.superlogical.terminal", "process", { block_id = block_id })
    local foreground = process and process.foreground
    if not foreground then
        return false
    end
    -- `name` is not always the executable's name, so check `argv0` too
    for _, executable in ipairs({ foreground.name or "", (foreground.argv0 or ""):match("[^/]*$") }) do
        for _, pattern in ipairs(patterns) do
            if executable:match(pattern) then
                return true
            end
        end
    end
    return false
end

-- Directional focus that returns to the pane you came from, like tmux/vim.
-- Rex's focus_direction picks the nearest pane and, on a tie, the top/left
-- one, so going back left from a full-height right pane always landed on the
-- top-left split. Panes are ranked by when they last had focus.
local focus_clock = 0
local last_focused = {} -- block_id -> focus_clock when it last had focus

local function mark_focused(block_id)
    focus_clock = focus_clock + 1
    last_focused[block_id] = focus_clock
end

local function tiled_rects(view)
    for _, window in ipairs(view and view.windows or {}) do
        if window.window_id == view.active_window_id then
            for _, layer in ipairs(window.layers or {}) do
                if layer.kind == "tiled" and layer.layout then
                    local rects = {}
                    local function walk(node)
                        if node.block_id then
                            rects[node.block_id] = node.rect
                        elseif node.split then
                            walk(node.split.before)
                            walk(node.split.after)
                        end
                    end
                    walk(layer.layout)
                    return rects
                end
            end
        end
    end
end

local edge_eps = 1e-4

-- Length of the overlap of [a1, a2] and [b1, b2]
local function overlap(a1, a2, b1, b2)
    return math.min(a2, b2) - math.max(a1, b1)
end

-- Whether rect `o` touches rect `c` on `direction` and shares part of that edge
local function is_neighbor(c, o, direction)
    local cx, cy, cw, ch = c[1], c[2], c[3], c[4]
    local ox, oy, ow, oh = o[1], o[2], o[3], o[4]
    if direction == "left" then
        return math.abs(ox + ow - cx) < edge_eps and overlap(oy, oy + oh, cy, cy + ch) > edge_eps
    elseif direction == "right" then
        return math.abs(ox - (cx + cw)) < edge_eps and overlap(oy, oy + oh, cy, cy + ch) > edge_eps
    elseif direction == "up" then
        return math.abs(oy + oh - cy) < edge_eps and overlap(ox, ox + ow, cx, cx + cw) > edge_eps
    elseif direction == "down" then
        return math.abs(oy - (cy + ch)) < edge_eps and overlap(ox, ox + ow, cx, cx + cw) > edge_eps
    end
    return false
end

-- The most recently focused pane next to `block_id` on `direction`, or nil to
-- leave the choice to Rex (focused pane is floating, or no neighbor has had
-- focus yet).
local function recent_neighbor(block_id, direction)
    local rects = tiled_rects(rex.session.view({}))
    local current = rects and rects[block_id]
    if not current then
        return nil
    end
    local best, best_seen = nil, 0
    for other_id, rect in pairs(rects) do
        local seen = last_focused[other_id] or 0
        if other_id ~= block_id and seen > best_seen and is_neighbor(current, rect, direction) then
            best, best_seen = other_id, seen
        end
    end
    return best
end

-- passthrough=false is for smart-splits.nvim's rex backend: nvim already
-- decided to leave its own window, so the key must not be sent back to it.
-- Returns { handled = true } when focus moved, which the backend needs to
-- know whether it hit the edge of the layout.
rex.action({
    name = "smart_splits_focus",
    title = "Smart Splits: Focus Pane",
    args = { direction = "string", key = "string?", passthrough = "boolean?" },
    run = function(ctx, args)
        local block_id = focused_block_id(ctx)
        if args.passthrough ~= false and foreground_matches(block_id, focus_passthrough_programs) then
            if not args.key then
                error("smart_splits_focus: no key given to forward to the program", 0)
            end
            send_key_to(ctx, block_id, args.key)
            return
        end
        -- Remember where we are even if it was reached with the mouse
        mark_focused(block_id)
        local target = recent_neighbor(block_id, args.direction)
        local _, err
        if target then
            _, err = rex.session.focus_block({ block_id = target })
        else
            _, err = rex.session.focus_direction({ direction = args.direction })
        end
        if err ~= nil then
            error(err, 0)
        end
        local now = focused_block_id(ctx)
        mark_focused(now)
        return { handled = now ~= block_id }
    end,
})

-- Floating panes: pane.resize only resizes splits, so grow/shrink the layer's
-- right and bottom edges instead (bounds are fractions of the window).
local float_resize_step = 0.05
local float_min_size = 0.1

local function floating_layer_of(block_id)
    local view = rex.session.view({})
    for _, window in ipairs(view and view.windows or {}) do
        for _, layer in ipairs(window.layers or {}) do
            if layer.kind == "floating" then
                for _, block in ipairs(layer.blocks or {}) do
                    if block.block_id == block_id then
                        return layer
                    end
                end
            end
        end
    end
end

local function resize_floating_layer(layer, direction)
    local b = layer.bounds or {}
    local x, y, w, h = b[1] or b.x, b[2] or b.y, b[3] or b.w, b[4] or b.h
    if direction == "right" then
        w = math.min(w + float_resize_step, 1 - x)
    elseif direction == "left" then
        w = math.max(w - float_resize_step, float_min_size)
    elseif direction == "down" then
        h = math.min(h + float_resize_step, 1 - y)
    elseif direction == "up" then
        h = math.max(h - float_resize_step, float_min_size)
    end
    local _, err = rex.session.resize_layer({ layer_id = layer.layer_id, bounds = { x, y, w, h } })
    if err ~= nil then
        error(err, 0)
    end
end

rex.action({
    name = "smart_splits_resize",
    title = "Smart Splits: Resize Pane",
    args = { direction = "string", key = "string?", amount = "number?" },
    run = function(ctx, args)
        local block_id = focused_block_id(ctx)
        if foreground_matches(block_id, vim_programs) then
            if not args.key then
                error("smart_splits_resize: no key given to forward to Neovim", 0)
            end
            send_key_to(ctx, block_id, args.key)
            return
        end
        local layer = floating_layer_of(block_id)
        if layer then
            resize_floating_layer(layer, args.direction)
            return
        end
        rex.client.queue("pane.resize", {
            direction = args.direction,
            amount = args.amount or default_resize_amount,
        })
    end,
})

-- Focus: ctrl+h/j/k/l (kitty pass_keys.py / vim-tmux-navigator)
rex.bind("ctrl+h", "smart_splits_focus", { direction = "left", key = "ctrl+h" })
rex.bind("ctrl+j", "smart_splits_focus", { direction = "down", key = "ctrl+j" })
rex.bind("ctrl+k", "smart_splits_focus", { direction = "up", key = "ctrl+k" })
rex.bind("ctrl+l", "smart_splits_focus", { direction = "right", key = "ctrl+l" })

-- Resize: ctrl+shift+arrows (kitty resize_window). Inside nvim this forwards
-- alt+h/j/k/l, which smart-splits.nvim maps to resize, so alt+l stays free to
-- type @ on the German layout everywhere else.
rex.bind("ctrl+shift+left", "smart_splits_resize", { direction = "left", amount = 5, key = "alt+h" })
rex.bind("ctrl+shift+down", "smart_splits_resize", { direction = "down", key = "alt+j" })
rex.bind("ctrl+shift+up", "smart_splits_resize", { direction = "up", key = "alt+k" })
rex.bind("ctrl+shift+right", "smart_splits_resize", { direction = "right", amount = 5, key = "alt+l" })
