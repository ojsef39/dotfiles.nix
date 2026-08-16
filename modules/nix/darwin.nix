{
  flake.modules.darwin.base = {
    nixSettings,
    pkgs,
    ...
  }: {
    # Determinate manages the nix daemon on darwin — disable the nix-darwin nix module
    nix = {
      enable = false;
      package = pkgs.nix;
    };

    determinateNix = {
      customSettings = nixSettings;
      determinateNixd.builder = {
        cpuCount = 4;
        memoryBytes = 8589934592; # 8.5GB
      };
    };

    # NOTE: Idk why this has to be set to 5
    # labels: question
    system.stateVersion = 5;
  };
}
