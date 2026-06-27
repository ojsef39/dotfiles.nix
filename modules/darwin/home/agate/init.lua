-- agate-wm configuration.
-- Loaded on startup from $WM_CONFIG, $XDG_CONFIG_HOME/agate/init.lua,
-- ~/.config/agate/init.lua, or ./init.lua (this file, for development).

-- Gaps and hyper-key definition.
agate.config({
	gaps = 8, -- space between tiles
	outer_gaps = 8, -- inset from the screen edge
	accordion_padding = 20, -- stacked-window "peek": how far each window fans out
	-- "hyper" expands to this modifier set in keyspecs below.
	hyper_key = { enabled = true, keys = { "ctrl", "alt", "cmd" } },
	-- Small Screen Mode: on the built-in display (or any display narrower than
	-- max_width points, when set), workspaces still on the default split layout
	-- become a horizontal accordion — splitting a tiny screen isn't useful.
	-- layout = "tabs" stacks windows full-size with no peek instead.
	-- Plugging in a big external display switches the workspaces back.
	small_screen = {
		enabled = true,
		layout = "h_accordion", -- or "tabs", "v_accordion", ...
		max_width = 0, -- 0 = built-in display detection only
	},
	-- UX.
	drag_preview = true, -- highlight the slot a dragged window will land in
	space_indicator = true, -- active space number in the menu bar
	-- Animate tiling frame changes: the final size applies instantly, the
	-- position glides over (60 Hz, ease-out). Off = exact snapping.
	animations = true,
	animation_duration = 150, -- milliseconds; lower = faster, 0 disables
	space_animation = "instant",
})

-- Trackpad gestures (the smooth-trackpad half of Small Screen Mode): a
-- three-finger swipe steps through the accordion, wrapping at the ends. A long
-- swipe keeps stepping, Hyprland-style. Works in any layout, not just small
-- mode. (Three-finger swipes must be free: set the system Mission Control /
-- page gestures to four fingers, or off, in Trackpad settings.)
agate.gesture("3:right", function()
	agate.cycle("next")
end)
agate.gesture("3:left", function()
	agate.cycle("prev")
end)

-- The same cycling from the keyboard.
agate.bind("hyper+tab", function()
	agate.cycle("next")
end)
agate.bind("hyper+shift+tab", function()
	agate.cycle("prev")
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
agate.bind("hyper+shift+g", function()
	agate.join("right", "v_split")
end) -- split with right neighbour

-- Resize the focused tile.
agate.bind("hyper+minus", function()
	agate.resize("smart", -50)
end)
agate.bind("hyper+plus", function()
	agate.resize("smart", 50)
end)

-- Instant space switching — uses SLSManagedDisplaySetCurrentSpace directly,
-- not gesture emulation (which fails on macOS 26+).
agate.bind("hyper+1", function()
	agate.space(1)
end)
agate.bind("hyper+2", function()
	agate.space(2)
end)
agate.bind("hyper+3", function()
	agate.space(3)
end)
agate.bind("hyper+4", function()
	agate.space(4)
end)
agate.bind("hyper+5", function()
	agate.space(5)
end)
agate.bind("hyper+6", function()
	agate.space(6)
end)
agate.bind("hyper+7", function()
	agate.space(7)
end)
agate.bind("hyper+8", function()
	agate.space(8)
end)
agate.bind("hyper+9", function()
	agate.space(9)
end)

-- Send the focused window to space N (does not follow focus).
agate.bind("hyper+shift+1", function()
	agate.move_to_space(1)
	agate.space(1)
end)
agate.bind("hyper+shift+2", function()
	agate.move_to_space(2)
	agate.space(2)
end)
agate.bind("hyper+shift+3", function()
	agate.move_to_space(3)
	agate.space(3)
end)
agate.bind("hyper+shift+4", function()
	agate.move_to_space(4)
	agate.space(4)
end)
agate.bind("hyper+shift+5", function()
	agate.move_to_space(5)
	agate.space(5)
end)
agate.bind("hyper+shift+6", function()
	agate.move_to_space(6)
	agate.space(6)
end)
agate.bind("hyper+shift+7", function()
	agate.move_to_space(7)
	agate.space(7)
end)
agate.bind("hyper+shift+8", function()
	agate.move_to_space(8)
	agate.space(8)
end)
agate.bind("hyper+shift+9", function()
	agate.move_to_space(9)
	agate.space(9)
end)

-- Cycle through spaces.
agate.bind("hyper+n", function()
	agate.space_next()
end)
agate.bind("hyper+p", function()
	agate.space_prev()
end)

agate.bind("hyper+f", function()
	agate.zoom_fullscreen()
end)

agate.bind("hyper+shift+f", function()
	agate.native_fullscreen()
end)

-- Multi-monitor. Windows on every display are tiled within that display's own
-- frame. Focus another monitor (its most-recently-used window becomes key), and
-- move the focused window to an adjacent monitor where it gets tiled too.
-- Directions: "next"/"prev" (cycle) or "left"/"right"/"up"/"down" (spatial).
agate.bind("hyper+comma", function()
	agate.focus_monitor("prev")
end)
agate.bind("hyper+period", function()
	agate.focus_monitor("next")
end)
agate.bind("hyper+shift+comma", function()
	agate.move_to_monitor("prev")
end)
agate.bind("hyper+shift+period", function()
	agate.move_to_monitor("next")
end)
-- A window can also be assigned to a specific space on a specific monitor:
-- agate.move_to_space(2, 2) sends it to space 2 of the second display.

-- Resolve displays by NAME, not spatial number (which flips when rearranged).
-- MSI G27CQ4 = main/middle · PHL 277E6 = left · Color LCD = built-in/right.
-- Returns each screen's monitor `id`, or nil when it isn't attached.
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

-- (Re)build the window assignment rules for the current display layout. Rules
-- (yabai-style) send a matching window to a monitor/space when it appears;
-- `app`/`title` are POSIX extended regexes (at least one required), last match
-- wins, `follow = false` routes in the background. Cleared first so re-running
-- on a display change doesn't pile duplicates up. The `or` fallbacks collapse
-- everything onto whatever screen is still attached when undocked.
local function apply_rules()
	agate.clear_rules()

	local msi, builtin, phl = survey_displays()
	local main = msi or builtin or phl -- middle (MSI when docked)
	local left = phl or builtin or msi -- Philips
	local right = builtin or msi or phl -- built-in laptop screen
	local has_external = msi ~= nil or phl ~= nil

	-- Main display (MSI, middle).
	agate.rule({ app = "^Zen Browser (Beta)$", monitor = main, space = 1 })
	agate.rule({ app = "^Moonlight$", monitor = main, space = 1 })
	agate.rule({ app = "^kitty$", monitor = main, space = 2 })
	agate.rule({ app = "^Obsidian$", monitor = main, space = 3 })
	agate.rule({ app = "^Things$", monitor = main, space = 3 })

	if has_external then
		agate.rule({ app = "^Firefox$", monitor = left, follow = false })
		agate.rule({ app = "^Vesktop$", monitor = right, follow = false })
		agate.rule({ app = "^Spotify$", monitor = right, space = 2, follow = false })
	else
		agate.rule({ app = "^Vesktop$", space = 4, follow = false })
		agate.rule({ app = "^Spotify$", space = 4, follow = false })
		agate.rule({ app = "^Firefox$", space = 9, follow = false })
	end
end

-- Apply now, and re-apply whenever a display is plugged in or unplugged so the
-- placement tracks docking/undocking instead of going stale.
apply_rules()
agate.on("monitors_changed", function(e)
	print(string.format("agate: monitors changed -> %d connected; reapplying rules", e.count))
	apply_rules()
end)

print("agate: config loaded")
