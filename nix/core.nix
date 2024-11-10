
{ pkgs, ... }:

{
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];
  };


  nixpkgs.config.allowBroken = true;

  # TODO: Idk why this has to be set to 5
  system.stateVersion = 5;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
