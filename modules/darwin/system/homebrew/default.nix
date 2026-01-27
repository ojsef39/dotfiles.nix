_: {
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

    taps = [
      "hashicorp/tap"
      "tldev/tap"
    ];

    # Mac App Store apps
    masApps = {
      "Reeder" = 6475002485;
      "The Unarchiver" = 425424353;
    };

    # Homebrew formulae (CLI tools)
    brews = [
      "ca-certificates"
      "coreutils"
      "expect"
      "hashicorp/tap/vault"
      "helm"
      "keyring"
      "mas"
      "ncdu"
      "norwoodj/tap/helm-docs"
      "renovate"
      "yazi"
    ];

    # macOS-specific apps and those not available/stable in nixpkgs
    casks = [
      "1password"
      "1password-cli"
      "arc"
      "caffeine"
      "dockdoor"
      "mac-mouse-fix"
      "poe"
      "postman"
      "posturr"
      "raycast"
      "scroll-reverser"
      "the-unarchiver"
      "yubico-authenticator"
    ];
  };
}
