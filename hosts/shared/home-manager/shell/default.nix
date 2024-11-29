{ pkgs, lib, vars, ... }:

{
  # Required packages
  home.packages = with pkgs; [
    coreutils
    eza
    fastfetch
    fzf
    git
    nodejs
    python3
    tmux
    yarn
    zoxide
  ];

  ##TODO: do you really have to still install it when its enabled?
  programs.zsh = {
    enable = lib.mkDefault true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    
    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = lib.mkDefault true;
      plugins = [ "git" "node" "npm" "github" ];
    };

    # Environment variables
    sessionVariables = {
      PATH = lib.concatStringsSep ":" [
        "/opt/homebrew/bin"
        "$HOME/Library/Python/3.12/bin"
        "/Users/${vars.user}/${vars.git.ghq}/github.com/ojsef39/commit-oracle"
        "$PATH"
      ];
      PYTHON = "/usr/bin/python3";
      GCL_TIMESTAMPS = "true";
      GCL_MAX_JOB_NAME_PADDING = "30";
      NODE_EXTRA_CA_CERTS="$(brew --prefix)/etc/ca-certificates/cert.pem";
      # GITLAB-CI-LOCAL
      GLC_CONTAINER_EXECUTEABLE = "podman";
      # Initialize spaceship prompt
      SPACESHIP_CHAR_SYMBOL="🚀 ";
      SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=true;
      SPACESHIP_DIR_PREFIX="🗂  ";
      SPACESHIP_GIT_BRANCH_PREFIX="⚡";
      SPACESHIP_PROMPT_SUFFIXES_SHOW=false;
      SPACESHIP_PROMPT_DEFAULT_PREFIX=" - ";
      SPACESHIP_EXEC_TIME_SHOW=false;
      SPACESHIP_GIT_PREFIX=" on ";
      SPACESHIP_DOCKER_PREFIX=" on ";
      SPACESHIP_PACKAGE_PREFIX=" is ";
      SPACESHIP_GIT_STATUS_SHOW="false";
    };

    ##TODO: Improve TMUX function (move away from tmux + make session name more readable)
    initExtra = ''
      autoload -U promptinit; promptinit
      bindkey -r "^j"

      # TMUX function
      # n() {
      #  local session_name=$(echo "$PWD" | rev | cut -d'/' -f1-5 | rev | tr '/' '-' | tr '.' '-' | tr ':' '-')
      #  # local session_name="$(basename "$PWD")"
      #   if [ -z "$TMUX" ]; then
      #     if tmux has-session -t "$session_name" 2>/dev/null; then
      #         tmux attach-session -t "$session_name"
      #     else
      #         tmux new-session -s "$session_name" "nvim $*"
      #     fi
      #   else
      #     nvim "$@"
      #   fi
      # }
      # compdef _files n

      t() {
          # local session_name=$(echo "$PWD" | rev | cut -d'/' -f1-5 | rev | tr '/' '-' | tr '.' '-' | tr ':' '-')
          local session_name="$(basename "$PWD")"
          if [ -z "$TMUX" ]; then
              if tmux has-session -t "$session_name" 2>/dev/null; then
                  tmux attach-session -t "$session_name"
              else
                  tmux new-session -s "$session_name"
              fi
          else
            echo "Already in a tmux session"
          fi
      }

      # diff function with default flags
      diffc() {
        diff -u -a "$@"
      }
      compdef _diff diffc

      # diff function using nvim
      diffn() {
        nvim -d "$@"
      }
      compdef _diff diffnV

      check_repos() {
        find . -type d -name ".git" | while read gitdir; do
          repo_dir="$(dirname "$gitdir")"
          if [ -n "$(git -C "''${repo_dir}" status --porcelain)" ]; then
            echo "changes in ''${repo_dir#./}"
          fi
        done
      }

      # Source additional scripts
      if [ -d $HOME/.zsh_scripts ]; then
        for file in $HOME/.zsh_scripts/*.zsh; do
          source $file
        done
      fi

      # Ensure fastfetch doesnt get on my nerves
      if [[ -z "$SKIP_FF" ]]; then
          if [ ! -f /tmp/fastfetch.lock ]; then
              # Create lock file with current kitty session PID
              echo $KITTY_PID > /tmp/fastfetch.lock
              fastfetch
          fi

          cleanup_fastfetch_lock() {
              if [ -f /tmp/fastfetch.lock ]; then
                  # Check if any kitty windows are still running
                  if ! pgrep -x kitty >/dev/null; then
                      rm /tmp/fastfetch.lock
                  fi
              fi
          }

          zshexit() {
              cleanup_fastfetch_lock
          }
      fi
      tmux list-sessions
    '';

    # Aliases
    shellAliases = {
      update-nix = "make -C ${vars.git.nix} update";
      please = "sudo";
      ls = "eza --icons --git --header";
      n = "nvim";
      x = "exit";
    };
    
    # Install and configure plugins separately
    plugins = [
      {
        name = "zsh-fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "spaceship-prompt";
        src = pkgs.spaceship-prompt;
        file = "share/zsh/site-functions/prompt_spaceship_setup";
      }
    ];
  };

  # Additional program configurations
  programs = {
    fzf = {
      enable = lib.mkDefault true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";  # Faster than find
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--color=spinner:#f4dbd6,hl:#ed8796"
        "--color=fg:#cad3f5,header:#cad3f5,info:#c6a0f6,pointer:#f4dbd6"
        "--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
      ];
    };
    zoxide = {
      enable = lib.mkDefault true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
    };
    # Terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          layout = [
            1
            4
            3
          ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "size_and_mtime";
          show_hidden = true;
          show_symlink = true;
        };
        preview = {
          image_filter = "lanczos3";
          image_quality = 90;
          tab_size = 1;
          max_width = 600;
          max_height = 900;
          cache_dir = "";
          ueberzug_scale = 1;
          ueberzug_offset = [
            0
            0
            0
            0
          ];
        };
        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };
      };
    };
    tmux = {
      enable = lib.mkDefault true;
      shell = "${pkgs.zsh}/bin/zsh";
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
    
  # Ensure tmux plugin manager is installed
  home = {
    file.".tmux/plugins/tpm".source = pkgs.fetchgit {
      url= "https://github.com/tmux-plugins/tpm";
      rev = "v3.1.0";
      sha256 = "sha256-IxguT6YgQNG9sE5773FIVgkddc2pGge/rLRDzopeBag=";
      leaveDotGit = false;
    };
    file = {
      ".zsh_scripts/" = {
        recursive = true;
        source = ./zsh_scripts;
      };
    };
  };
}
