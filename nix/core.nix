{
  pkgs,
  lib,
  ...
}: {
  nix = {
    enable =
      if pkgs.stdenv.isDarwin
      then false
      else true;
    settings = {
      lazy-trees = true;
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # substituters = [
      #   "https://nix-community.cachix.org"
      # ];
      # trusted-public-keys = [
      #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # ];
    };
    package = pkgs.nix;
  };
  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  environment.etc."nix/nix.custom.conf" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      # Written by base/nix/core.nix
      lazy-trees = true
      extra-experimental-features = parallel-eval
      eval-cores = 0
    '';
  };

  # TODO: Idk why this has to be set to 5
  system.stateVersion = 5;
}
