{
  config,
  pkgs,
  vars,
  ...
}: {
  programs.kitty = {
    enable = true;

    # Settings
    settings = {
      # Environment
      term = "xterm-256color";
      editor = "nvim";

      # Window
      window_padding_width = "2 2";
      draw_minimal_borders = "yes";
      background_opacity = "0.8";
      background_blur = "25";
      remember_window_size = "yes";
      initial_window_width = "640";
      initial_window_height = "400";
      confirm_os_window_close = "1";
      hide_window_decorations = "titlebar-only";
      enabled_layouts = "splits:split_axis=horizontal";

      # Titlebar
      wayland_titlebar_color = "background";

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "-1";
      cursor_stop_blinking_after = "30.0";
      cursor_trail = "1";

      # Scrolling
      scrollback_lines = "10000";
      scrollback_indicator_opacity = "0.5";

      # Copy behavior
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";

      # Undercurl and URLs
      undercurl_style = "thin-dense";
      url_style = "curly";
      show_hyperlink_targets = "yes";

      # Mouse
      mouse_hide_wait = "1.0";

      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      visual_bell_color = "none";
      window_alert_on_bell = "no";

      # Tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{index} {'' if 'fish' in tab.active_exe else tab.active_exe.split('/')[-1] + ': '}{tab.active_wd.split('/')[-1] if 'fish' in tab.active_exe else (title.split('/')[-1] if '/' in title else title)}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      # Remote control
      remote_kitty = "if-needed";
      startup_session = "startup.conf";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";

      # Fonts
      font_family = "Maple Mono NF";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      disable_ligatures = "cursor";

      # Set font size based on system because on linux wayland, font zise 13 is huge for some reason
      font_size =
        if pkgs.stdenv.isDarwin
        then "14"
        else "10";
      modify_font = "cell_height 100%";

      macos_option_as_alt = "both";
    };

    mouseBindings = {
      "b4" = "press grabbed,ungrabbed previous_tab";
      "b5" = "press grabbed,ungrabbed next_tab";
    };

    keybindings = {
      "ctrl+shift+-" = "launch --location=hsplit --cwd=current";
      "ctrl+shift++" = "launch --location=vsplit --cwd=current";
      "f4" = "launch --location=split";
      "f1" = "launch --stdin-source=@screen_scrollback --stdin-add-formatting less +G -R";
      "ctrl+shift+h" = "move_window left";
      "ctrl+shift+j" = "move_window down";
      "ctrl+shift+k" = "move_window up";
      "ctrl+shift+l" = "move_window right";
      "ctrl+j" = "kitten ~/.config/kitty/scripts/pass_keys.py bottom ctrl+j";
      "ctrl+k" = "kitten ~/.config/kitty/scripts/pass_keys.py top    ctrl+k";
      "ctrl+h" = "kitten ~/.config/kitty/scripts/pass_keys.py left   ctrl+h";
      "ctrl+l" = "kitten ~/.config/kitty/scripts/pass_keys.py right  ctrl+l";
      "ctrl+shift+left" = "resize_window wider 5";
      "ctrl+shift+right" = "resize_window narrower 5";
      "ctrl+shift+up" = "resize_window taller";
      "ctrl+shift+down" = "resize_window shorter";
      "ctrl+shift+x" = "close_window";
      "ctrl+shift+m" = "launch --type=tab --cwd=current --copy-env --title Yazi -- env SKIP_FF=1 ${pkgs.fish}/bin/fish -c 'yazi'";
      "ctrl+shift+p" = "launch --title 'Project Selector' --copy-env --type=overlay env SKIP_FF=1 ${pkgs.fish}/bin/fish -c '~/.config/kitty/scripts/project_selector.sh'";
      "cmd+left" = "previous_tab";
      "cmd+right" = "next_tab";
      ##
      "alt+left" = "send_text all \\x1bb";
      "alt+right" = "send_text all \\x1bf";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      "cmd+0" = "goto_tab 10";
      # Preserve Option/Alt +  combinations for special characters
      "opt+5" = "send_text all [";
      "opt+6" = "send_text all ]";
      "opt+7" = "send_text all |";
      "opt+8" = "send_text all {";
      "opt+9" = "send_text all }";
      "opt+n" = "send_text all ~";
      "opt+l" = "send_text all @";
      "opt+-" = "send_text all –"; # en dash
      "opt+shift+7" = "send_text all \\\\"; # backslash
      "opt+shift+-" = "send_text all —"; # em dash
    };
    extraConfig = ''
      include ${config.xdg.configHome}/kitty/themes/catppuccin-macchiato.conf
      include ${config.xdg.configHome}/kitty/quick-access-terminal.conf
    '';
  };

  xdg.configFile = {
    "kitty/themes/catppuccin-macchiato.conf".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/kitty/refs/heads/main/themes/macchiato.conf";
      hash = "sha256-1fF00Gm1cf5iXX2QIhqxxwYAbStyL5LBUR6wP82hO74=";
    };

    "kitty/quick-access-terminal.conf".source = ./quick-access-terminal.conf;

    # Copy icon
    "kitty/kitty.app.png".source = ./themes/kitty.app.png;

    # Executable scripts
    "kitty/scripts" = {
      source = ./scripts;
      recursive = true;
    };

    "kitty/scripts/project_selector.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        ghq_root=~/${vars.git.ghq}
        project_dirs=(${vars.kitty.project_selector})

        # Parse command line arguments
        no_nvim=false
        for arg in "$@"; do
          case $arg in
            --no-nvim)
              no_nvim=true
              shift
              ;;
          esac
        done

        # Function to find git repositories under the ghq root path
        git_repos() {
          find "$ghq_root" -type d -name ".git" | sed 's/\/.git$//'
        }

        # Display the git repositories and subfolders of the project directories
        projects() {
          git_repos
          for dir in "$project_dirs"; do
            find "$dir" -maxdepth 1 -type d | tail -n +2 # List subdirectories only, excluding the base directory itself
          done
        }

        # Select a project directory using fzf
        project_selector() {
          local project
          project=$(projects | fzf --height 100%)
          if [ -n "$project" ]; then
            if [ "$no_nvim" = true ]; then
              # Only change to the directory without opening nvim
              kitten @ launch --copy-env --type=tab --cwd="$project" -- env SKIP_FF=1 ${pkgs.fish}/bin/fish -c "cd '$project'"
              echo "Changed to $project"
            else
              # Change directory and open nvim (original behavior)
              kitten @ launch --copy-env --type=tab --cwd="$project" -- env SKIP_FF=1 ${pkgs.fish}/bin/fish -c "cd '$project' && nvim ."
              echo "Changed to $project"
            fi
          else
            echo "No project selected."
          fi
        }
        project_selector
      '';
    };
  };
}
