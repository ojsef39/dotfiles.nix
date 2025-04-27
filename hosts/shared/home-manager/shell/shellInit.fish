fish_config theme choose "Catppuccin Macchiato"

# Set PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/Library/Python/3.12/bin
fish_add_path $HOME/.local/bin

# Tide configuration
set -U tide_git_icon '⚡'

# Source additional scripts
if test -d $HOME/.fish_scripts
    for file in $HOME/.fish_scripts/*.fish
        source $file
    end
end

# Ensure fastfetch doesnt get on my nerves
if test -z "$SKIP_FF"
    if not test -f /tmp/fastfetch.lock
        # Create lock file with current kitty session PID
        echo $KITTY_PID >/tmp/fastfetch.lock
        fastfetch
    end

    function cleanup_fastfetch_lock --on-event fish_exit
        if test -f /tmp/fastfetch.lock
            # Check if any kitty windows are still running
            if not pgrep -x kitty >/dev/null
                rm /tmp/fastfetch.lock
            end
        end
    end
end

# Show tmux sessions on startup
tmux list-sessions 2>/dev/null
