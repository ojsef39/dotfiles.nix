{ pkgs, vars, lib, ... }:

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
  # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you
  # will also want to enable the fish shell in /etc/nixos/configuration.nix:
  programs.fish.enable = true;

  # User configuration (needed for fish to work as default shell: https://github.com/nix-darwin/nix-darwin/issues/1237)
  users = {
    users = {
      ${vars.user} = {
        shell = pkgs.fish;
        uid = 501;
      };
    };
    knownUsers = [ "${vars.user}" ];
  };

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts = {
      postUserActivation.text = ''
        # activateSettings -u will reload the settings from the database and apply them to the current session,
        # so we do not need to logout and login again to make the changes take effect.
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };

    startup.chime = lib.mkDefault true;

    defaults = {
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };

      NSGlobalDomain = {
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
      };
      WindowManager = {
        GloballyEnabled = true;
        EnableStandardClickToShowDesktop = true;
        HideDesktop = false;
        StageManagerHideWidgets = false;
      };

      alf.stealthenabled = 1; ##TODO: Move to personal

      menuExtraClock = {
        ShowDate = 1;
        ShowSeconds = true;
      };

      spaces.spans-displays = false;

      hitoolbox.AppleFnUsageType = "Show Emoji & Symbols";
    };
  };
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
