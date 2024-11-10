{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    # Theme
    #theme = "Catppuccin";

    # Settings
    settings = {
      # Colors
      url_color = "#4dc6ff";

      # Environment
      term = "xterm-256color";
      editor = "nvim";

      # Window
      window_padding_width = "2 2";
      draw_minimal_borders = "yes";
      # background_opacity = "0.8";
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
      tab_title_template = "{index} { tab.active_exe if tab.active_exe not in ('-zsh', 'kitten') else title}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
      active_tab_background = "#8aadf4";

      # Remote control
      remote_kitty = "if-needed";
      startup_session = "startup.conf";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";

      # Fonts
      font_family = "JetBrainsMono Nerd Font Mono";
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


    ##TODO: Add mouse buttons to switch tabs
    # Keybindings
    keybindings = {
      "ctrl+shift+-" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+=" = "launch --location=vsplit --cwd=current";
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
      "ctrl+shift+left" = "resize_windo wider 5";
      "ctrl+shift+right" = "resize_window narrower 5";
      "ctrl+shift+up" = "resize_window taller";
      "ctrl+shift+down" = "resize_window shorter";
      "ctrl+shift+x" = "close_window";
      "ctrl+shift+m" = "launch --type=tab --cwd=current --copy-env --title Yazi -- zsh -il -c \"yazi\"";
      "ctrl+shift+p" = "launch --title \"Project Selector\" --copy-env --type=overlay zsh -il -c \"~/.config/kitty/scripts/project_selector.sh\"";
      "cmd+left" = "send_text all \\x01";
      "cmd+right" = "send_text all \\x05";
      "alt+left" = "send_text all \\x1b[1;3D";
      "alt+right" = "send_text all \\x1b[1;3C";
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
    };

    # Extra configuration to ensure catpuccin theme is included
    # extraConfig = ''
    #   include ${config.xdg.configHome}/kitty/themes/catpuccin.conf
    # '';
  };

  xdg.configFile = {
    # Copy pass_keys.py
    "kitty/scripts/pass_keys.py".source = ./scripts/pass_keys.py;

    # Copy theme
    "kitty/themes/catpuccin.conf".source = ./themes/catpuccin.conf;

    # Copy icon
    "kitty/themes/kitty.app.png".source = ./themes/kitty.app.png;

    # If you have a project selector script
    "kitty/scripts/project_selector.sh".source = ./scripts/project_selector.sh;
  };
}
