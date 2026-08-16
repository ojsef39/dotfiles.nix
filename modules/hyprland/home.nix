{
  flake.modules.homeManager.josef-nd1-gpu0 = {
    pkgs,
    inputs,
    ...
  }: let
    # TODO: dendritic pattern with flake-parts
    # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/506
    # examples/resources:
    # https://github.com/frostplexx/dotfiles.nix/pull/694
    # https://youtu.be/-TRbzkw6Hjs?si=BcNzUCxE9QJJwDwd
    rose-pine-hyprcursor = inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default;

    catppuccin-hyprland = pkgs.fetchurl {
      # Pinned: upstream replaced the .conf themes with .lua themes for Hyprland 0.55+,
      # so the file no longer exists on main.
      url = "https://raw.githubusercontent.com/catppuccin/hyprland/b57375545f5da1f7790341905d1049b1873a8bb3/themes/macchiato.conf";
      sha256 = "1f8fr5sf220g4pc7vcg2cs51rzp49a7dgr8rlwspybvmz9wdc3c8";
    };
  in {
    nix.settings = {
      extra-substituters = ["https://hyprland.cachix.org"];
      extra-trusted-substituters = ["https://hyprland.cachix.org"];
      extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    # NOTE: If something is broken or didnt change try following first:
    # 1. `hyperctl reload'
    # 2. `pkill -f caelestia-shell` wait a sec and then `caelestia shell -d &`

    home.packages = [rose-pine-hyprcursor];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";

      settings = {
        # ── Monitor ──────────────────────────────────────────────
        monitor = [
          "HDMI-A-1, 2560x1440@120, auto, 1"
        ];

        # ── Input ────────────────────────────────────────────────
        input = {
          kb_layout = "de";
          follow_mouse = 1;
          sensitivity = -0.3;
          scroll_factor = 0.27;
          touchpad = {
            natural_scroll = true;
            scroll_factor = 0.4;
          };
        };

        # ── General ──────────────────────────────────────────────
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "$blue $mauve 45deg";
          "col.inactive_border" = "$surface0";
          layout = "dwindle";
          allow_tearing = false;
        };

        # ── Decoration ──────────────────────────────────────────
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 6;
            passes = 3;
            new_optimizations = true;
            xray = false;
          };
          shadow = {
            enabled = true;
            range = 20;
            render_power = 3;
            color = "rgba(1a1a2eee)";
          };
        };

        # ── Animations ──────────────────────────────────────────
        animations = {
          enabled = true;
          bezier = [
            "ease, 0.25, 0.1, 0.25, 1"
            "easeOut, 0, 0, 0.58, 1"
            "easeInOut, 0.42, 0, 0.58, 1"
            "overshot, 0.05, 0.9, 0.1, 1.05"
          ];
          animation = [
            "windows, 1, 5, overshot, popin 80%"
            "windowsOut, 1, 5, easeOut, popin 80%"
            "border, 1, 8, ease"
            "borderangle, 1, 30, ease, loop"
            "fade, 1, 5, ease"
            "workspaces, 1, 5, overshot, slide"
          ];
        };

        # ── Layout ──────────────────────────────────────────────
        dwindle = {
          # NOTE: pseudotile option removed in Hyprland 0.55.x — use the
          # `pseudo` dispatcher (already bound to SUPER+P) instead.
          preserve_split = true;
          force_split = 2; # always split to the right/bottom
        };

        # ── Misc ────────────────────────────────────────────────
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 0; # disable VRR to avoid flickering with NVIDIA
        };

        # ── Cursor ──────────────────────────────────────────────
        env = [
          "HYPRCURSOR_THEME,rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE,24"
        ];

        # ── Autostart ───────────────────────────────────────────
        exec-once = [
          "caelestia shell -d"
          "systemctl --user start sunshine"
        ];

        source = ["${catppuccin-hyprland}"];

        # ── Keybindings ─────────────────────────────────────────
        bind = [
          # ── Window focus (vim-like) ──
          "SUPER, H, movefocus, l"
          "SUPER, J, movefocus, d"
          "SUPER, K, movefocus, u"
          "SUPER, L, movefocus, r"

          # ── Move windows (SUPER+Ctrl to avoid SUPER+Shift+L macOS conflict) ──
          "SUPER CTRL, H, movewindow, l"
          "SUPER CTRL, J, movewindow, d"
          "SUPER CTRL, K, movewindow, u"
          "SUPER CTRL, L, movewindow, r"

          # ── Close window ──
          "SUPER, Q, killactive"

          # ── Applications ──
          "SUPER, Return, exec, ${pkgs.kitty}/bin/kitty"
          "SUPER, D, exec, caelestia shell drawers toggle launcher"

          # ── Window management ──
          "SUPER, F, fullscreen, 1" # maximize (keep bar)
          "SUPER SHIFT, F, fullscreen, 0" # true fullscreen
          "SUPER, V, togglefloating"
          "SUPER, P, pseudo" # dwindle pseudotile
          "SUPER, S, layoutmsg, togglesplit" # dwindle toggle split direction
          "SUPER SHIFT, D, togglespecialworkspace"

          # ── Workspaces ──
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"

          # ── Move window to workspace (avoid SUPER+SHIFT for screenshot conflicts) ──
          "SUPER CTRL, 1, movetoworkspace, 1"
          "SUPER CTRL, 2, movetoworkspace, 2"
          "SUPER CTRL, 3, movetoworkspace, 3"
          "SUPER CTRL, 4, movetoworkspace, 4"
          "SUPER CTRL, 5, movetoworkspace, 5"
          "SUPER CTRL, 6, movetoworkspace, 6"
          "SUPER CTRL, 7, movetoworkspace, 7"
          "SUPER CTRL, 8, movetoworkspace, 8"
          "SUPER CTRL, 9, movetoworkspace, 9"

          # ── Workspace scroll ──
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
          "SUPER, Page_Down, workspace, e+1"
          "SUPER, Page_Up, workspace, e-1"

          # ── Monitor navigation ──
          "SUPER, comma, focusmonitor, l"
          "SUPER, period, focusmonitor, r"
          "SUPER CTRL, comma, movewindow, mon:l"
          "SUPER CTRL, period, movewindow, mon:r"

          # ── Screenshots ──
          ", Print, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
          "SUPER, Print, exec, ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"

          # ── System ──
          "SUPER SHIFT, E, exit"
          # "SUPER CTRL, P, dpms, off" # turn off display
        ];

        # ── Resize with Ctrl+Alt+HJKL (repeatable, avoids CMD+Alt macOS conflicts) ──
        binde = [
          "CTRL ALT, H, resizeactive, -30 0"
          "CTRL ALT, L, resizeactive, 30 0"
          "CTRL ALT, K, resizeactive, 0 -30"
          "CTRL ALT, J, resizeactive, 0 30"
        ];

        # ── Mouse bindings ──
        bindm = [
          "SUPER, mouse:272, movewindow" # SUPER + left click drag
          "SUPER, mouse:273, resizewindow" # SUPER + right click drag
        ];

        # Window rules in block form below (extraConfig).
      };

      extraConfig = ''
        windowrule {
          name = suppress_maximize
          match:class = .*
          suppress_event = maximize
        }
        windowrule {
          name = float_pavucontrol
          match:class = ^(pavucontrol)$
          float = 1
        }
        windowrule {
          name = float_nm
          match:class = ^(nm-connection-editor)$
          float = 1
        }
        windowrule {
          name = float_open
          match:title = ^(Open File)$
          float = 1
        }
        windowrule {
          name = float_save
          match:title = ^(Save File)$
          float = 1
        }
      '';
    };
  };
}
