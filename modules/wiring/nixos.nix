{
  config,
  inputs,
  ...
}: {
  # NixOS counterpart of ./darwin.nix.
  flake.modules.nixos.base.imports = [
    inputs.determinate.nixosModules.default
    inputs.nix-flatpak.nixosModules.nix-flatpak
    {nixpkgs.overlays = [inputs.virtualhere.overlays.default];}
    inputs.home-manager.nixosModules.home-manager
    inputs.nixkit.nixosModules.default
    (
      {vars, ...}: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {
            inherit vars inputs;
            baseLib = config.flake.lib;
          };
          sharedModules = [
            inputs.nix-index-database.homeModules.default
            inputs.nixcord.homeModules.nixcord
            inputs.nixkit.homeModules.default
            inputs.spicetify-nix.homeManagerModules.default
            inputs.zen-browser.homeModules.beta
            inputs.caelestia-shell.homeManagerModules.default
          ];
          users.${vars.user.name}.imports = [
            config.flake.modules.homeManager.base
            config.flake.modules.homeManager.nixos
          ];
        };
      }
    )
  ];
}
