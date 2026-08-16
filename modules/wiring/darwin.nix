{
  config,
  inputs,
  ...
}: {
  # Everything a consumer needs to get a working nix-darwin + home-manager base:
  # the third-party system modules, the home-manager wiring, and the base
  # home-manager aggregates mounted onto the configured user.
  flake.modules.darwin.base.imports = [
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
            config.flake.modules.homeManager.base
            config.flake.modules.homeManager.darwin
          ];
        };
      }
    )
  ];
}
