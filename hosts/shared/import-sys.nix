{
  vars,
  pkgs,
  ...
}: let
  # Check if system directory exists
  hasSystemDir = builtins.pathExists ./system;

  # Get all immediate subdirectories of ./system if it exists, otherwise empty list
  systemDirs =
    if hasSystemDir
    then builtins.attrNames (builtins.readDir ./system)
    else [];

  # Filter only directories that actually have a default.nix
  validSystemDirs =
    builtins.filter (
      dir: builtins.pathExists (./system + "/${dir}/default.nix")
    )
    systemDirs;

  # Map each valid directory to its default.nix path
  systemModules = map (dir: ./system/${dir}/default.nix) validSystemDirs;

  # Determine home directory based on system
in {
  imports =
    systemModules
    ++ [
      ./apps.nix
    ];
}
