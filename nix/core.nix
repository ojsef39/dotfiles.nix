{ pkgs, ... }:

{
  nix = {
    settings = {
      # enable flakes globally
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    package = pkgs.nix;
  };
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  # TODO: Idk why this has to be set to 5
  system.stateVersion = 5;
}
