{vars, ...}: let
  dotPath = "/Users/${vars.user.name}/${vars.git.ghq}/github.com/ojsef39/dotfiles.nix";
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
