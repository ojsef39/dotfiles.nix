# The catppuccin port selects the fish theme (see modules/catppuccin.nix).

# Set PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/Library/Python/3.12/bin
fish_add_path $HOME/.local/bin
# Rex prepends its bin dir to PATH for new panes, but the PATH rebuild drops it
if set -q REX_BIN_DIR; and not contains -- $REX_BIN_DIR $PATH
    set -gx PATH $REX_BIN_DIR $PATH
end
# done plugin: skip commands that already notify through Rex (claude, rex-track).
# First pattern is done's default; this runs after the plugin set it, so restate it.
set -g __done_exclude '^git (?!push|pull|fetch)' '(^|[;&|]\s*)(claude|rex-track)(\s|$)'

# Fish / Tide configuration
set -U fish_greeting " "
set -U tide_git_icon '⚡'

# Source additional scripts
if test -d $HOME/.fish_scripts
    for file in $HOME/.fish_scripts/*.fish
        source $file
    end
end

function _fish_greeting
    fortune -s | cowsay -r | fastfetch -l -
end

# Ensure fastfetch doesnt get on my nerves
if test -z "$SKIP_FF"
    if test -S (string replace -r '^unix:' '' -- "$KITTY_LISTEN_ON"); and command -sq jq
        set _kitty_total_tab_count_output (kitty @ --to "$KITTY_LISTEN_ON" ls | jq 'map(try .tabs | length) | add // 0' 2>/dev/null)
        if test $status -eq 0; and test "$_kitty_total_tab_count_output" -eq "$_kitty_total_tab_count_output" 2>/dev/null
            if test "$_kitty_total_tab_count_output" -eq 1
                _fish_greeting
            end
        end
    else if set -q REX_BLOCK; and command -sq rex; and command -sq jq
        # Rex: greet only in the first pane (the whole server holds one block)
        set _rex_block_count (rex block ls --json 2>/dev/null | jq '.blocks | length' 2>/dev/null)
        if test "$_rex_block_count" = 1
            _fish_greeting
        end
    end
end

# Show tmux sessions on startup
if command -sq tmux
    tmux list-sessions 2>/dev/null
end
