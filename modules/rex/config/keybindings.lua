-- Migrated from tmux, Ghostty and kitty. Every source line that could not be
-- migrated is listed in the migration report, not here.

---------------------------------------------------------------------------
-- tmux (prefix ctrl+space)
---------------------------------------------------------------------------
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+space>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+space>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+space>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+space>shift+h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("repeat/shift+h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("ctrl+space>shift+j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("repeat/shift+j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("ctrl+space>shift+k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("repeat/shift+k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("ctrl+space>shift+l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("repeat/shift+l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
rex.bind("ctrl+space>b", "pane.send_key", { key = "ctrl+space" })
rex.bind("ctrl+space>r", "client.config.reload")
rex.bind("ctrl+space>j", "pane.split", { direction = "down" })
rex.bind("ctrl+space>l", "pane.split", { direction = "right" })
rex.bind("ctrl+space>left", "pane.resize", { amount = 1, direction = "left" })
rex.bind("repeat/left", "pane.resize", { amount = 1, direction = "left" })
rex.bind("ctrl+space>down", "pane.resize", { amount = 1, direction = "down" })
rex.bind("repeat/down", "pane.resize", { amount = 1, direction = "down" })
rex.bind("ctrl+space>up", "pane.resize", { amount = 1, direction = "up" })
rex.bind("repeat/up", "pane.resize", { amount = 1, direction = "up" })
rex.bind("ctrl+space>right", "pane.resize", { amount = 1, direction = "right" })
rex.bind("repeat/right", "pane.resize", { amount = 1, direction = "right" })
rex.bind("ctrl+space>ctrl+b", "pane.send_key", { key = "ctrl+l" })

---------------------------------------------------------------------------
-- Ghostty / kitty (keys both bound to the same thing are written once)
---------------------------------------------------------------------------
-- Command palette on cmd+p; this frees shift+cmd+p for 1Password Quick Access
rex.bind("cmd+p", "client.palette.toggle")

-- Splits: Rex's defaults cmd+d (right) and shift+cmd+d (down), same in kitty
rex.bind("f4", "pane.split", { direction = "auto" })
rex.bind("ctrl+shift+x", "pane.close")
rex.bind("ctrl+shift+delete", "com.superlogical.terminal.clear")
rex.bind("cmd+o", "session.switch")
rex.bind("cmd+left", "client.tab.previous")
rex.bind("cmd+right", "client.tab.next")
rex.bind("cmd+9", "client.tab.goto", { index = 9 })
rex.bind("cmd+0", "client.tab.goto", { index = -1 })

-- MXL switch escape (FS, ctrl+\)
rex.bind("f12", "pane.send_key", { key = "ctrl+\\" })

-- German-layout Option remaps (opt = alt). send_text types the character
-- itself; pane.send_key dropped the shift ("@" came out as "2").
rex.bind("alt+5", "send_text", { text = "[" })
rex.bind("alt+6", "send_text", { text = "]" })
rex.bind("alt+7", "send_text", { text = "|" })
rex.bind("alt+8", "send_text", { text = "{" })
rex.bind("alt+9", "send_text", { text = "}" })
rex.bind("alt+n", "send_text", { text = "~" })
rex.bind("alt+l", "send_text", { text = "@" })
rex.bind("alt+shift+7", "send_text", { text = "\\" })
rex.bind("alt+-", "send_text", { text = "–" }) -- en dash
rex.bind("alt+shift+-", "send_text", { text = "—" }) -- em dash

-- kitty move_window
rex.bind("ctrl+shift+h", "pane.move", { direction = "left" })
rex.bind("ctrl+shift+j", "pane.move", { direction = "down" })
rex.bind("ctrl+shift+k", "pane.move", { direction = "up" })
rex.bind("ctrl+shift+l", "pane.move", { direction = "right" })

-- ctrl+h/j/k/l focus and ctrl+shift+arrows resize live in smart_splits.lua

---------------------------------------------------------------------------
-- From frostplexx's config
---------------------------------------------------------------------------
rex.bind("cmd+e", "pane.zoom")
rex.bind("shift+cmd+e", "pane.float") -- float / dock again, next to zoom
rex.bind("cmd+s", "floating_term")
rex.bind("cmd+g", "lazygit_float")
rex.bind("ctrl+shift+m", "yazi_float")
rex.bind("ctrl+shift+p", "session_new_project")
