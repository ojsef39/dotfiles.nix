{
  config,
  inputs,
  ...
}: let
  m = config.flake.modules;
in {
  # The single module a downstream macOS flake imports. It pulls in the
  # platform-agnostic base itself, so a consumer needs nothing but
  # `base.modules.darwin.base` plus their own `vars`.
  flake.modules.darwin.base.imports = [
    m.generic.base
    inputs.determinate.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    inputs.nixkit.darwinModules.default
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
          ];
          users.${vars.user.name}.imports = [
            m.homeManager.base
            m.homeManager.darwin
          ];
        };
      }
    )
  ];
}
