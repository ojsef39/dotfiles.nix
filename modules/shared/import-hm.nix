{
  vars,
  pkgs,
  lib,
  baseLib,
  ...
}: let
  homeDirectory = baseLib.mkHome vars pkgs;
in {
  imports = baseLib.scanPaths ./home;

  home = {
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
