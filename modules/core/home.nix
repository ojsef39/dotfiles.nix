{
  flake.modules.homeManager.base = {
    vars,
    pkgs,
    lib,
    baseLib,
    ...
  }: {
    home = {
      homeDirectory = lib.mkForce (baseLib.mkHome vars pkgs);
      stateVersion = "24.05";
    };

    programs.home-manager.enable = true;
  };
}
