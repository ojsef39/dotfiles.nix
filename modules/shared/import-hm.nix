{
  vars,
  pkgs,
  lib,
  baseLib,
  ...
}: let
  homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user.name}"
    else "/home/${vars.user.name}";
in {
  imports = baseLib.scanPaths ./home;

  home = {
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
