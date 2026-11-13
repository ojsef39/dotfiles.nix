{
  flake.modules.darwin.base = {
    lib,
    vars,
    ...
  }: {
    # Homebrew for macOS-specific and unavailable packages
    # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "uninstall"; # "zap" to also remove config files
      };

      taps = [];

      # Mac App Store apps
      masApps = lib.mkIf vars.masApps.enable {
        "Reeder" = 6475002485;
        "The Unarchiver" = 425424353;
        "Things 3" = 904280696;
      };

      # Homebrew formulae (CLI tools)
      brews = [
        "ca-certificates"
        "coreutils"
        "expect"
        "keyring"
        "mas"
        "ncdu"
        "yazi"
      ];

      # macOS-specific apps and those not available/stable in nixpkgs
      casks = [
        "caffeine"
        "firefox"
        "postman"
        "raycast"
        "scroll-reverser"
        "the-unarchiver"
        "yubico-authenticator"
      ];
    };
  };

  flake.modules.darwin.personal = _: {
    homebrew.casks = [
      "dockdoor"
      "dorso"
      "tor-browser"
    ];
  };
}
