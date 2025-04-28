{ vars, pkgs, lib, ... }:
let
  # Check if home-manager directory exists
  hasHomeManagerDir = builtins.pathExists ./home-manager;

  # Get all immediate subdirectories of ./home-manager if it exists, otherwise empty list
  homeManagerDirs = if hasHomeManagerDir
    then builtins.attrNames (builtins.readDir ./home-manager)
    else [];

  # Filter only directories that actually have a default.nix
  validHomeManagerDirs = builtins.filter
    (dir: builtins.pathExists (./home-manager + "/${dir}/default.nix"))
    homeManagerDirs;

  # Map each valid directory to its default.nix path
  homeModules = map (dir: ./home-manager/${dir}/default.nix) validHomeManagerDirs;

  # Determine home directory based on system
  homeDirectory = if pkgs.stdenv.isDarwin
    then "/Users/${vars.user.name}"
    else "/home/${vars.user.name}";

in
{
  imports = homeModules;

  home = {
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
