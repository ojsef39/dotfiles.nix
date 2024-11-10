{ vars, pkgs, lib, ... }:
let
  # Check if programs directory exists
  hasProgramsDir = builtins.pathExists ./programs;

  # Get all immediate subdirectories of ./programs if it exists, otherwise empty list
  programDirs = if hasProgramsDir
    then builtins.attrNames (builtins.readDir ./programs)
    else [];

  # Filter only directories that actually have a default.nix
  validProgramDirs = builtins.filter
    (dir: builtins.pathExists (./programs + "/${dir}/default.nix"))
    programDirs;

  # Map each valid directory to its default.nix path
  programModules = map (dir: ./programs/${dir}/default.nix) validProgramDirs;

  # Determine home directory based on system
  homeDirectory = if pkgs.stdenv.isDarwin
    then "/Users/${vars.user}"
    else "/home/${vars.user}";

in
{
  imports = programModules;

  home = {
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
