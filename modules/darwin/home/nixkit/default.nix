{
  vars,
  pkgs,
  baseLib,
  ...
}: let
  dotPath = baseLib.mkDotPath vars pkgs;
in {
  programs = {
    mac-mouse-fix.enable = true;
    default-browser = {
      enable = true;
      browser = "zen"; # browser = Arc.
    };
    nixupdater = {
      enable = true;
      flake = dotPath;
      terminal = "kitty-tab";
      command = "NIX_GIT_PATH=${dotPath} just upgrade";
    };
  };
}
