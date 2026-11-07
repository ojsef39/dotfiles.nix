---@diagnostics disable: undefined-global
-- Lookups in the active window's session view, shared by the actions that need
-- to know which pane has focus or which float is open.
local M = {}

-- The pane that has focus right now, floats included; falls back to the
-- action's own block when the view has none
function M.focused_block_id(ctx)
    local view = rex.session.view({})
    for _, window in ipairs(view and view.windows or {}) do
        if window.window_id == view.active_window_id and window.focused_block_id then
            return window.focused_block_id
        end
    end
    return ctx.block_id
end

-- The floating layer in the active window holding a block labeled `label`, or
-- nil. Pass `view` to reuse one already fetched.
function M.floating_layer_with_label(label, view)
    view = view or rex.session.view({})
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

return M
