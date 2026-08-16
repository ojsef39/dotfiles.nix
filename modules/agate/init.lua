-- agate injects its API as the gloachl `agate`, invisible to the linters — quiet
-- the "undefined variable" noise from lua_ls and luacheck for this file.
-- luacheck: ignore 113
---@diagnostic disable: undefined-global

-- Gaps and hyper-key definition.
agate.config({
    gaps = 4, -- space between tiles
    outer_gaps = 4, -- inset from the screen edge
    accordion_padding = 20, -- stacked-window "peek": how far each window fans out
    hyper_key = { enabled = true, keys = { "ctrl", "alt", "cmd" } },
    smart_gaps = true, -- disable gaps when only one tile is visible
})

-- Gestures
agate.gesture("3:left", function()
    agate.focus("right")
end)
agate.gesture("3:down", function()
    agate.focus("down")
end)
agate.gesture("3:up", function()
    agate.focus("up")
end)
agate.gesture("3:right", function()
    agate.focus("left")
end)

-- Focus movement (i3-style hjkl).
agate.bind("hyper+h", function()
    agate.focus("left")
end)
agate.bind("hyper+j", function()
    agate.focus("down")
end)
agate.bind("hyper+k", function()
    agate.focus("up")
end)
agate.bind("hyper+l", function()
    agate.focus("right")
end)

agate.bind("hyper+comma", function()
    agate.focus_monitor("left")
end)
agate.bind("hyper+period", function()
    agate.focus_monitor("right")
end)

agate.bind("hyper+shift+comma", function()
    agate.move_to_monitor("left")
end)
agate.bind("hyper+shift+period", function()
    agate.move_to_monitor("right")
end)

agate.bind("hyper+f", function()
    agate.zoom_fullscreen()
end)

agate.bind("hyper+shift+f", function()
    agate.native_fullscreen()
end)

-- Cycle through spaces.
agate.bind("hyper+n", function()
    agate.space_next()
end)
agate.bind("hyper+p", function()
    agate.space_prev()
end)

-- Cycle through windows (accordion step), wrapping at the ends.
agate.bind("hyper+tab", function()
    agate.cycle("next")
end)
agate.bind("hyper+shift+tab", function()
    agate.cycle("prev")
end)

-- Move the focused window to an adjacent slot.
agate.bind("hyper+shift+h", "move left")
agate.bind("hyper+shift+j", "move down")
agate.bind("hyper+shift+k", "move up")
agate.bind("hyper+shift+l", "move right")

-- Layout control.
agate.bind("hyper+b", function()
    agate.layout("h_tiles")
end) -- horizontal split
agate.bind("hyper+v", function()
    agate.layout("v_tiles")
end) -- vertical split
agate.bind("hyper+e", function()
    agate.layout("toggle")
end) -- swap split orientation
agate.bind("hyper+a", function()
    agate.layout("float")
end) -- swap split orientation
agate.bind("hyper+s", function()
    agate.layout("accordion")
end) -- vertical stack (bottom peeks)
agate.bind("hyper+shift+s", function()
    agate.layout("h_stack")
end) -- horizontal stack

-- Combine the focused window with a neighbour into a nested container, for mixed
-- layouts (e.g. left/right tiled with the left slot holding two stacked windows).
-- Second arg is the new container's layout (default "v_stack").
agate.bind("hyper+g", function()
    agate.join("right")
end) -- stack with right neighbour
-- ungroup? https://github.com/frostplexx/agate-wm/issues/17
-- agate.bind("hyper+shift+g", function()
-- 	agate.join("right", "v_tiles")
-- end) -- split with right neighbour

-- Resize the focused tile.
agate.bind("hyper+minus", function()
    agate.resize("smart", -50)
end)
agate.bind("hyper+plus", function()
    agate.resize("smart", 50)
end)

-- Per-monitor space navigation: hyper+1..9 switches the focused monitor to its
-- Nth space; hyper+shift+N sends the focused window there and follows. These are
-- plain numbers (NOT the named spaces below) so the keys never jump you to
-- another display — use hyper+comma/period to change monitors.
for i = 1, 9 do
    agate.bind("hyper+" .. i, function()
        agate.space(i)
    end)
    agate.bind("hyper+shift+" .. i, function()
        agate.move_to_space(i)
        agate.space(i)
    end)
end

-- Identify displays by NAME rather than by number, because `agate.monitors()`
-- numbers displays by spatial position (left→right), which flips when you
-- rearrange screens. MSI G27CQ4 = main/middle · PHL 277E6 = left · built-in
-- ("Built-in"/"Color LCD") = right. Returns each screen's monitor `id`, or nil
-- when it isn't attached.
local function survey_displays()
    local msi, builtin, phl = nil, nil, nil
    for _, m in ipairs(agate.monitors()) do
        if m.name:find("Built-in", 1, true) or m.name:find("Color LCD", 1, true) then
            builtin = m.id
        elseif m.name:find("MSI", 1, true) then
            msi = m.id
        elseif m.name:find("PHL", 1, true) then
            phl = m.id
        end
    end
    return msi, builtin, phl
end

-- Window assignment rules (yabai-style): a matching window is sent to a space
-- when it appears; `app`/`title` are POSIX extended regexes (at least one
-- required), last match wins. These are STATIC — they reference named spaces by
-- name, and agate resolves the name (and its monitor) each time a window appears,
-- so a rule automatically follows the dynamic music/comms remapping below without
-- being re-registered.
agate.rule({ app = "^Zen Browser (Beta)$", space = "web" })
agate.rule({ app = "^Moonlight$", space = "web" })
agate.rule({ app = "^kitty$", space = "term" })
agate.rule({ app = "^Obsidian$", space = "notes" })
agate.rule({ app = "^Things$", space = "notes" })
agate.rule({ app = "^Linear$", space = "notes" })
agate.rule({ title = "^Calendar | Microsoft Teams$", space = "notes" }) -- Meeting

agate.rule({ app = "^Vesktop$", space = "comms", follow = false })
agate.rule({ title = "^Microsoft Teams$", space = "comms", follow = false }) -- Chat
agate.rule({ app = "^Signal$", space = "comms", follow = false })
agate.rule({ app = "^WhatsApp$", space = "comms", follow = false })
agate.rule({ app = "^Spotify$", space = "music", follow = false })
agate.rule({ app = "^Firefox$", space = "watch", follow = false })

-- (Re)declare the named spaces for the current display layout. Named spaces
-- (`agate.name_space`) give a (monitor, space) slot a name, so the binds and
-- rules above can say "music" instead of a monitor+number; the same name works in
-- `agate.space`, `agate.move_to_space`, and `agate.rule{space=...}`. This is the
-- only dynamic part: re-run on every display change (a name overwrites its old
-- slot), so the music/comms spaces follow docking. `monitor` is the 1-based
-- arrangement number from `agate.monitors()`; omit it to mean "the focused
-- display".
local function name_spaces()
    local msi, builtin, phl = survey_displays()
    local main = msi or builtin or phl -- middle (MSI when docked, else whatever's attached)
    local left = phl or builtin or msi -- Philips
    local right = builtin or msi or phl -- built-in laptop screen
    local has_external = msi ~= nil or phl ~= nil

    -- The three primary spaces always live on the main (middle) display.
    agate.name_space("web", { monitor = main, space = 1 }) -- Zen / Moonlight
    agate.name_space("term", { monitor = main, space = 2 }) -- kitty
    agate.name_space("notes", { monitor = main, space = 3 }) -- Obsidian / Things
    if has_external then
        -- Docked: side apps get their own monitors.
        agate.name_space("watch", { monitor = left, space = 1 }) -- Philips, left
        agate.name_space("comms", { monitor = right, space = 1 }) -- built-in, right
        agate.name_space("music", { monitor = right, space = 2 }) -- built-in, right
    else
        -- Laptop only: collapse onto the built-in panel (matches the old layout).
        agate.name_space("comms", { monitor = right, space = 4 })
        agate.name_space("music", { monitor = right, space = 5 })
        agate.name_space("watch", { monitor = right, space = 9 })
    end
end

-- Name the spaces now, and re-name them whenever a display is plugged in or
-- unplugged so music/comms track docking/undocking.
name_spaces()
agate.on("monitors_changed", function(e)
    print(string.format("agate: monitors changed -> %d connected; renaming spaces", e.count))
    name_spaces()
end)

print("agate: config loaded")
