---@diagnostics disable: undefined-global
-- Type literal text into the focused pane. pane.send_key reads keys on a US
-- layout and drops the shift on the way (shift+2 came out as "2", not "@"),
-- and cannot send non-US characters such as "–" at all. A key event that
-- carries the text arrives as typed.

local function focused_block_id(ctx)
    local view = rex.session.view({})
    for _, window in ipairs(view and view.windows or {}) do
        if window.window_id == view.active_window_id and window.focused_block_id then
            return window.focused_block_id
        end
    end
    return ctx.block_id
end

rex.action({
    name = "send_text",
    title = "Send Text",
    args = { text = "string" },
    run = function(ctx, args)
        local block_id = focused_block_id(ctx)
        for _, action in ipairs({ "press", "release" }) do
            local _, err = rex.call("block.event", {
                session_id = ctx.session_id,
                block_id = block_id,
                event = {
                    type = "key",
                    payload = {
                        key = "key_space",
                        mods = "",
                        consumed_mods = "",
                        text = args.text,
                        -- Rex's Lua has no utf8 library; the text field is what
                        -- the terminal sends, so the first byte is enough here
                        unshifted_codepoint = string.byte(args.text, 1),
                        composing = false,
                        action = action,
                    },
                },
            })
            if err ~= nil then
                error(err, 0)
            end
        end
    end,
})
