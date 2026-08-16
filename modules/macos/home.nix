{
  flake.modules.homeManager.darwin = _: {
    targets = {
      darwin = {
        linkApps.enable = false;
        copyApps.enable = true;
        # defaults -currentHost read com.apple.screensaver
        currentHostDefaults = {
          "com.apple.screensaver" = {
            idleTime = 180; # extends power settings in ../system/system.nix
            showClock = 1;
          };
        };
      };
    };
  };
}
