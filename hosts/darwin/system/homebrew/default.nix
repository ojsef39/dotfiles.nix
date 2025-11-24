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
    ];

    # Mac App Store apps
    masApps = {
      "Reeder" = 1529448980;
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
      "logi-options+"
      "mac-mouse-fix"
      "poe"
      "postman"
      "raycast"
      "scroll-reverser"
      "the-unarchiver"
      "yubico-authenticator"
    ];
  };
}
