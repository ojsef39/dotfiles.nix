{
  vars,
  pkgs,
  baseLib,
  ...
}: let
  dotPath = baseLib.mkDotPath vars pkgs;
in {
  programs = {
    default-browser = {
      enable = true;
      browser = "zen"; # browser = Arc.
    };
    nixupdater = {
      enable = true;
      flake = dotPath;
      command = "NIX_GIT_PATH=${dotPath} just upgrade";
    };
  };
}
