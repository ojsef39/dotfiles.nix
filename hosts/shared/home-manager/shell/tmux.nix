{
  pkgs,
  lib,
  ...
}: {
  programs = {
    tmux = {
      enable = lib.mkDefault true;
      shell = "${pkgs.fish}/bin/fish";
      baseIndex = 1;
      clock24 = true;
      customPaneNavigationAndResize = true;
      escapeTime = 0;
      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-Space";
      terminal = "xterm-256color";
      plugins = with pkgs.tmuxPlugins; [
        continuum
        copycat
        open
        resurrect
        yank
        vim-tmux-navigator
      ];

      extraConfig = ''
        # Unbind default prefix and set to C-Space
        unbind C-b
        bind-key C-space send-prefix

        # Clipboard settings
        set-option -s set-clipboard on

        # Copy mode bindings
        bind-key V copy-mode
        bind-key -T copy-mode-vi V send-keys -X cancel
        bind-key -T copy-mode-vi 'C-v' send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi v send-keys -X begin-selection

        # OS-specific copy-paste bindings
        if-shell "[[ $(uname) == 'Darwin' ]]" {
          bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
          bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
        }{
          bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
          bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
        }

        # Send prefix to nested session
        bind-key b send-prefix

        # Window and pane settings
        set-option -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Config reload
        bind-key r source-file ~/.tmux.conf \; display "🚀 Config reloaded."

        # Pane splitting
        unbind -
        unbind %
        unbind '"'
        unbind '|'
        bind-key j split-window -v -c "#{pane_current_path}"
        bind-key l split-window -h -c "#{pane_current_path}"

        # Pane resizing
        bind-key -r Left  resize-pane -L 1
        bind-key -r Down  resize-pane -D 1
        bind-key -r Up    resize-pane -U 1
        bind-key -r Right resize-pane -R 1

        # Secondary binding for C-l
        bind-key C-b send-keys 'C-l'

        # Activity monitoring
        set-window-option -g monitor-activity off
        set-option -g visual-activity on

        # Focus events
        set -g focus-events on

        # Status bar configuration
        set-option -g status "on"
        set-option -g status-interval 1
        set-option -g status-justify "centre"
        set-option -g status-style "bg=default"

        set-option -g status-left-length 50
        set-option -g status-left  '#[fg=#7aa2f7,bg=default]#h #[fg=#3b4261,bold,bg=default]• #[fg=#e0af68,bg=default]#(uname -s) #[fg=#3b4261,bold,bg=default]• #[fg=#f7768e,bg=default]#S #[fg=#3b4261,bold,bg=default]• #[fg=#f7768e,bg=default]#W #[fg=#3b4261,bold]• #[fg=#f7768e]#P #[fg=#3b4261,bold]'
        set-option -g status-right-length 140
        set-option -g status-right '#[fg=#f7768e,bg=default]#(uptime | cut -f 3-5 -d " " | cut -f 1 -d "," | tr -s " " | tr "u" "U")#[fg=#3b4261,bold,bg=default] • #[fg=#e0af68,bg=default]%a %Y-%m-%d#[fg=#3b4261,bold,bg=default] • #[fg=#7aa2f7,bg=default]%H:%M:%S#[fg=#3b4261,bold,bg=default]'

        # Pane colors
        set-option -g mode-style "fg=#7aa2f7,bg=#3b4261"
        set-option -g display-time 1500
        set-option -g message-command-style "fg=#7aa2f7,bg=#3b4261"
        set-option -g message-style "fg=#7aa2f7,bg=#3b4261"
        set-option -g pane-active-border-style "fg=#7aa2f7"
        set-option -g pane-border-style "fg=#3b4261"

        # Window status
        set-window-option -g window-status-separator ""
        set-window-option -g window-status-current-format ""
        set-window-option -g window-status-format ""

        # Word navigation with Alt/Option
        bind-key -n M-Left send-keys M-b
        bind-key -n M-Right send-keys M-f

        # Word navigation with Alt/Option
        bind-key -n M-Left send-keys M-b
        bind-key -n M-Right send-keys M-f

        # Line navigation with Cmd (beginning/end of line)
        bind-key -n C-Left send-keys C-a
        bind-key -n C-Right send-keys C-e

        # Home and End keys
        set-option -g xterm-keys on
        bind-key -n Home send-keys C-a
        bind-key -n End send-keys C-e

        # Copy mode navigation
        bind-key -T copy-mode-vi M-Left send-keys -X previous-word
        bind-key -T copy-mode-vi M-Right send-keys -X next-word
        bind-key -T copy-mode-vi C-Left send-keys -X start-of-line
        bind-key -T copy-mode-vi C-Right send-keys -X end-of-line
        bind-key -T copy-mode-vi Home send-keys -X start-of-line
        bind-key -T copy-mode-vi End send-keys -X end-of-line
      '';
    };
  };
}
