{lib}: let
  scanPaths = import ./scanPaths.nix {inherit lib;};
  helpers = import ./helpers.nix {};
in {
  inherit (scanPaths) scanPaths;
  inherit
    (helpers)
    makeOverlay
    mkHome
    mkDotPath
    mkHomeManagerModules
    mkOpAgentSock
    ;
}
