{
  flake.modules.nixos.josef-nd1-gpu0 = {
    config,
    lib,
    pkgs,
    vars,
    ...
  }: let
    onNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  in {
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
      nautilus-open-any-terminal = {
        enable = true;
        terminal = "kitty";
      };
    };

    services = {
      desktopManager.plasma6.enable = false;
      displayManager.sddm.enable = false;
      greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${pkgs.hyprland}/bin/Hyprland";
            user = vars.user.name;
          };
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
            user = "greeter";
          };
        };
      };

      # Kernel-level remapping for the Mac keyboard `<` and `^` swap issue
      # Moonlight sends standard PC evdev scancodes, but physically from Mac's layout.
      keyd = {
        enable = true;
        keyboards.default = {
          ids = ["*"]; # Apply to all virtual/physical keyboards
          settings.main = {
            "102nd" = "grave"; # Map the physical ISO key to ^
            "grave" = "102nd"; # Map the physical top-left key to <
          };
        };
      };
    };

    environment = {
      etc = lib.mkIf onNvidia {
        "nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json" = {
          text = ''
            {
                "rules": [
                    {
                        "pattern": {
                            "feature": "procname",
                            "matches": "Hyprland"
                        },
                        "profile": "Limit Free Buffer Pool On Wayland Compositors"
                    },
                    {
                        "pattern": {
                            "feature": "procname",
                            "matches": "sunshine"
                        },
                        "profile": "Limit Free Buffer Pool On Wayland Compositors"
                    }
                ],
                "profiles": [{
                    "name": "Limit Free Buffer Pool On Wayland Compositors",
                    "settings": [{
                        "key": "GLVidHeapReuseRatio",
                        "value": 0
                    }]
                }]
            }
          '';
        };
      };
      sessionVariables =
        {
          NIXOS_OZONE_WL = "1";
          XDG_SESSION_TYPE = "wayland";
        }
        // lib.optionalAttrs onNvidia {
          GBM_BACKEND = "nvidia-drm";
          LIBVA_DRIVER_NAME = "nvidia";
          NVD_BACKEND = "direct";
          WLR_NO_HARDWARE_CURSORS = "1";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
      systemPackages = with pkgs; [
        # FIX: nautilis is kinda broken
        # labels: os:nix
        nautilus
        swaylock # Screen lock
        wl-clipboard # Clipboard utilities
        grim # Screenshot
        slurp # Region selection
        hyprpaper # Wallpaper
        brightnessctl # Brightness control
        playerctl # Media control
        cliphist # Clipboard manager
      ];
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      config.common.default = "*";
    };
  };
}
