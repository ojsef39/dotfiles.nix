{
  flake.modules.homeManager.base =
    # Caveats vs. the previous kitty setup — workflows that don't port cleanly:
    #
    # 1. Seamless ctrl+h/j/k/l between ghostty splits and nvim splits.
    #    Kitty had this via pass_keys.py (detected if nvim was active). Ghostty
    #    can't detect what's running in the surface and the plugin/IPC system
    #    (ghostty-org/ghostty#2353) isn't being actively built — maintainer
    #    shelved the escape-sequence approach over security concerns and is
    #    leaning toward platform-specific IPC instead, with no timeline.
    #    smart-splits.nvim does NOT support ghostty as a multiplexer.
    #    → Current workflow here: ghostty tabs + nvim splits only.
    #      ctrl+h/j/k/l keep working inside nvim; for moving between ghostty
    #      panes use cmd+alt+arrows (ghostty default) or cmd+[ / cmd+].
    #
    # 2. ctrl+shift+h/j/k/l (kitty move_window — rearrange split positions).
    #    No keybind-equivalent action exists in ghostty.
    #    → Workaround: drag splits with the mouse to rearrange.
    #
    # 3. ctrl+shift+r (kitty layout_action rotate).
    #    No equivalent action in ghostty, not on any roadmap.
    #
    # 4. f1 scrollback-in-less, ctrl+shift+m (Yazi tab), ctrl+shift+p
    #    (project selector) were kitty-specific `kitten launch` invocations.
    #    Ghostty cannot exec arbitrary commands from a keybind.
    #    → Project selector reachable via fish abbr `ghql` (see shell/default.nix).
    #
    # 5. Mouse-button bindings (kitty mouseBindings b4/b5 for tab switching).
    #    Ghostty has no mouse-binding system — discussion ghostty-org/ghostty#3848
    #    confirms it's unsupported with no plans. Side-button tab switching is gone.
    {pkgs, ...}: {
      programs.ghostty = {
        enable = true;
        enableFishIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        package =
          if pkgs.stdenv.isDarwin
          then pkgs.ghostty-bin
          else pkgs.ghostty;

        settings = {
          theme = "Catppuccin Macchiato";

          font-family = "Maple Mono NF";
          font-size = 14;
          font-thicken = true;
          font-thicken-strength = 200; # 0 = lightest, 255 = heaviest (default)

          background-opacity = 0.8;
          background-blur = "macos-glass-regular";
          window-padding-x = 2;
          window-padding-y = 2;
          window-save-state = "always";
          window-decoration = true;
          confirm-close-surface = true;

          macos-titlebar-style = "tabs";
          macos-titlebar-proxy-icon = "hidden";
          macos-window-buttons = "hidden";
          macos-window-shadow = false;
          macos-option-as-alt = true;

          cursor-style = "block";
          cursor-style-blink = false;
          mouse-hide-while-typing = true;
          mouse-scroll-multiplier = "precision:1,discrete:1"; # default discrete:3 felt way too fast
          copy-on-select = "false";

          shell-integration = "fish";
          shell-integration-features = true;

          unfocused-split-opacity = 0.9;
          notify-on-command-finish = "unfocused";
          auto-update = "off";

          keybind = [
            # Command palette on cmd+p (default cmd+shift+p collides with 1Password)
            "cmd+shift+p=unbind"
            "cmd+p=toggle_command_palette"

            # Splits (kitty parity)
            "ctrl+shift+-=new_split:down"
            "ctrl+shift++=new_split:right"
            "f4=new_split:auto"

            # Split resize
            "ctrl+shift+left=resize_split:left,5"
            "ctrl+shift+right=resize_split:right,5"
            "ctrl+shift+up=resize_split:up,5"
            "ctrl+shift+down=resize_split:down,5"

            # Close current split/window
            "ctrl+shift+x=close_surface"

            # Clear screen + scrollback
            "ctrl+shift+delete=clear_screen"

            # Tab navigation (kitty muscle memory; overrides ghostty's cmd+arrow line-start/end)
            "cmd+left=previous_tab"
            "cmd+right=next_tab"
            # cmd+1..8 already mapped to goto_tab by default. Shift the row one key right:
            "cmd+9=goto_tab:9"
            "cmd+0=last_tab"
            "cmd+ß=reset_font_size"

            # Exit nvim terminal mode: <C-\><C-n>
            "ctrl+alt+n=text:\\x1c\\x0e"

            # MXL switch escape (FS, file separator)
            "f12=text:\\x1c"

            # German-layout Option remaps (macos-option-as-alt eats the OS-level translation)
            "alt+5=text:["
            "alt+6=text:]"
            "alt+7=text:|"
            "alt+8=text:{"
            "alt+9=text:}"
            "alt+n=text:~"
            "alt+l=text:@"
            "alt+-=text:–"
            "alt+shift+7=text:\\\\"
            "alt+shift+-=text:—"

            # No-ghostty-equivalent bindings (left here for reference; uncomment if a workaround appears):
            # ctrl+shift+h/j/k/l (kitty move_window) — ghostty only has goto_split, not move_split
            # ctrl+j/k/h/l (kitty pass_keys vim-tmux-navigator) — needs smart-splits.nvim integration in nvf
            # ctrl+shift+r (kitty layout_action rotate) — no ghostty equivalent
          ];
        };
      };
    };
}
