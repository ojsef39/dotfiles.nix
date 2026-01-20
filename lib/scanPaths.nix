{lib}: {
  # Helper function to auto-discover modules in a directory
  # Returns a list of paths to import
  # Supports both .nix files and directories with default.nix
  scanPaths = path: let
    # Safe readDir that returns empty set if path doesn't exist
    readDirSafely = p:
      if builtins.pathExists p
      then builtins.readDir p
      else {};

    entries = readDirSafely path;

    mapModules = name: type: let
      fullPath = path + "/${name}";
      isNixFile = type == "regular" && (lib.hasSuffix ".nix" name) && name != "default.nix";
      isDirectoryWithDefault = type == "directory" && builtins.pathExists (fullPath + "/default.nix");
    in
      if isNixFile
      then fullPath
      else if isDirectoryWithDefault
      then (fullPath + "/default.nix")
      else null;
  in
    lib.filter (x: x != null) (lib.mapAttrsToList mapModules entries);
}
