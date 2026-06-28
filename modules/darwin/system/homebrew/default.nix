{
  lib,
  vars,
  ...
}: {
  # Homebrew for macOS-specific and unavailable packages
  # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall"; # "zap" to also remove config files
    };

    taps = [];

    # Mac App Store apps
    masApps = lib.mkIf (vars.masApps.enable or true) {
      "Reeder" = 6475002485;
      "The Unarchiver" = 425424353;
    };

    # Homebrew formulae (CLI tools)
    brews = [
      "ca-certificates"
      "coreutils"
      "expect"
      "keyring"
      "mas"
      "ncdu"
      "renovate"
      "yazi"
    ];

    # macOS-specific apps and those not available/stable in nixpkgs
    casks = [
      "arc"
      "caffeine"
      "dockdoor"
      "dorso"
      "firefox"
      "poe"
      "postman"
      "raycast"
      "scroll-reverser"
      "the-unarchiver"
      "tor-browser"
      "yubico-authenticator"
    ];
  };
}
