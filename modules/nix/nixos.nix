{
  flake.modules.nixos.base = {nixSettings, ...}: {
    nix.settings = nixSettings;
  };
}
