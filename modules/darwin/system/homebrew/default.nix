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
      # TODO: Remove brew extraFlag after PR was merged
      # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/1366
      # Homebrew >= 5.1 requires --force-cleanup for `brew bundle --cleanup`;
      # nix-darwin doesn't pass it yet: https://github.com/nix-darwin/nix-darwin/issues/1787
      extraFlags = ["--force-cleanup"];
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
      "norwoodj/tap/helm-docs"
      "renovate"
      "yazi"
    ];

    # macOS-specific apps and those not available/stable in nixpkgs
    casks = [
      "arc"
      "caffeine"
      "dockdoor"
      "poe"
      "postman"
      "dorso"
      "raycast"
      "scroll-reverser"
      "the-unarchiver"
      "tor-browser"
      "yubico-authenticator"
    ];
  };
}
