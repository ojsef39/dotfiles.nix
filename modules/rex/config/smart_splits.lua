-- Neovim and Rex panes behave as one grid for smart-splits.nvim (based on
-- frostplexx/dotfiles.nix). When nvim is in the foreground the key is forwarded
-- to it, otherwise Rex moves focus / resizes itself.
local default_resize_amount = 3

local function is_vim_foreground(ctx)
    local process = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    local foreground = process and process.foreground
    if not foreground then
        return false
    end
    -- `name` is not always the executable's name, so check `argv0` too
    for _, executable in ipairs({ foreground.name or "", (foreground.argv0 or ""):match("[^/]*$") }) do
        if executable:match("^n?vim") then
            return true
        end
    end
    return false
end

rex.action({
    name = "smart_splits_focus",
    title = "Smart Splits: Focus Pane",
    args = { direction = "string", key = "string?" },
    run = function(ctx, args)
        if is_vim_foreground(ctx) then
            if not args.key then
                error("smart_splits_focus: no key given to forward to Neovim", 0)
            end
            rex.client.queue("pane.send_key", { key = args.key })
            return
        end
        local _, err = rex.session.focus_direction({ direction = args.direction })
        if err ~= nil then
            error(err, 0)
        end
    end,
})

rex.action({
    name = "smart_splits_resize",
    title = "Smart Splits: Resize Pane",
    args = { direction = "string", key = "string?", amount = "number?" },
    run = function(ctx, args)
        if is_vim_foreground(ctx) then
            if not args.key then
                error("smart_splits_resize: no key given to forward to Neovim", 0)
            end
            rex.client.queue("pane.send_key", { key = args.key })
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
