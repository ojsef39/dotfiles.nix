{
  lib,
  nixpkgs,
}: let
  scanPaths = import ./scanPaths.nix {inherit lib;};
  helpers = import ./helpers.nix {inherit nixpkgs;};
in {
  inherit (scanPaths) scanPaths;
  inherit (helpers) makeOverlay makePackages forAllSystems;
}
