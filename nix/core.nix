
{ pkgs, ... }:

{
  nix = {
    settings = {
      # enable flakes globally
      experimental-features = ["nix-command" "flakes"];
    };
    package = pkgs.nix;
  };
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  # TODO: Idk why this has to be set to 5
  system.stateVersion = 5;
}
