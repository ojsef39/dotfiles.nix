fish_config theme choose "Catppuccin Macchiato"

# Set PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/Library/Python/3.12/bin
fish_add_path $HOME/.local/bin

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
    if test -n "$KITTY_LISTEN_ON"; and command -sq jq
        set _kitty_total_tab_count_output (kitty @ --to "$KITTY_LISTEN_ON" ls | jq 'map(try .tabs | length) | add // 0' 2>/dev/null)
        if test $status -eq 0; and test "$_kitty_total_tab_count_output" -eq "$_kitty_total_tab_count_output" 2>/dev/null
            if test "$_kitty_total_tab_count_output" -eq 1
                _fish_greeting
            end
        end
    end
end

# Show tmux sessions on startup
tmux list-sessions 2>/dev/null
