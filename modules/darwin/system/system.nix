{
  pkgs,
  vars,
  lib,
  ...
}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
#  See your own values with for example: `defaults read com.apple.dock tilesize`
#
###################################################################################
{
  # User configuration (needed for fish to work as default shell: https://github.com/nix-darwin/nix-darwin/issues/1237)
  users = {
    users = {
      ${vars.user.name} = {
        shell = pkgs.fish;
        inherit (vars.user) uid;
      };
    };
    knownUsers = ["${vars.user.name}"];
  };

  system = {
    primaryUser = "${vars.user.name}";

    startup.chime = lib.mkDefault true;

    defaults = {
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };

      NSGlobalDomain = {
        NSWindowShouldDragOnGesture = true;
        NSAutomaticCapitalizationEnabled = false;
        "com.apple.trackpad.scaling" = 0.6875;
        "com.apple.sound.beep.volume" = 1.0;
      };

      ##TODO: Is this even still used?
      ".GlobalPreferences"."com.apple.mouse.scaling" = 0.6875;

      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.CustomSystemPreferences
      CustomSystemPreferences = {};

      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.CustomUserPreferences
      # Lock the dock after Apps were set by upstream
      CustomUserPreferences = {
        "com.apple.dock" = {
          # "contents-immutable" = 1;
          "size-immutable" = 1;
          "position-immutable" = 1;
        };
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        _FXShowPosixPathInTitle = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";

        ShowPathbar = true;
        ShowStatusBar = true;
      };

      dock = {
        magnification = true;
        largesize = 62;
        show-recents = true;
        tilesize = 54;
        wvous-bl-corner = 11;
        wvous-br-corner = 14;
        wvous-tl-corner = 5;
        wvous-tr-corner = 5; # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.wvous-tl-corner
        mru-spaces = false;
      };
      WindowManager = {
        GloballyEnabled = true;
        EnableStandardClickToShowDesktop = true;
        HideDesktop = false;
        StageManagerHideWidgets = false;
      };

      menuExtraClock = {
        ShowDate = 1;
        ShowSeconds = true;
      };

      spaces.spans-displays = false;

      hitoolbox.AppleFnUsageType = "Show Emoji & Symbols";
    };

    # Configure nix-daemon to use 1Password SSH agent for remote builders
    # Uses PlistBuddy to modify the Determinate-managed plist directly
    activationScripts = {
      preActivation.text = ''
        plist="/Library/LaunchDaemons/systems.determinate.nix-daemon.plist"
        desired="/Users/${vars.user.name}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

        current=$(/usr/libexec/PlistBuddy -c "Print :EnvironmentVariables:SSH_AUTH_SOCK" "$plist" 2>/dev/null || echo "")

        if [ "$current" != "$desired" ]; then
          /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables dict" "$plist" 2>/dev/null || true
          /usr/libexec/PlistBuddy -c "Set :EnvironmentVariables:SSH_AUTH_SOCK '$desired'" "$plist" 2>/dev/null || \
          /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:SSH_AUTH_SOCK string '$desired'" "$plist"

          if launchctl print system/systems.determinate.nix-daemon &>/dev/null; then
            launchctl unload /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
            launchctl load /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
          fi
        fi
      '';

      # example for linux
      # systemd.services.nix-daemon = {
      #   environment = {
      #     SSH_AUTH_SOCK = "/run/user/${builtins.toString config.users.users.${username}.uid}/${
      #       config.home-manager.users.${username}.services.ssh-agent.socket
      #     }";
      #   };
      # };
    };
  };
  networking.applicationFirewall.enableStealthMode = true;
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    watchIdAuth = true;
  };
}
