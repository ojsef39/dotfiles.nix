_: {
  # Create an overlay that exposes packages with custom vars
  # Usage: nixpkgs.overlays = [(base.lib.makeOverlay vars)];
  makeOverlay = vars: _final: prev:
    import ../packages {
      pkgs = prev;
      inherit vars;
    };

  # Build the home-manager wiring module list for a given platform.
  # hmModule:      home-manager.darwinModules.home-manager or .nixosModules.home-manager
  # nixkitModule:  nixkit.darwinModules.default or .nixosModules.default
  # platformImport: ./modules/darwin/import-hm.nix or ./modules/nixos/import-hm.nix
  mkHomeManagerModules = {
    hmModule,
    nixkitModule,
    platformImport,
    inputs,
    baseLib,
    extraHmModules ? [],
  }: [
    hmModule
    nixkitModule
    (
      {vars, ...}: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {
            inherit vars inputs baseLib;
          };
          users.${vars.user.name} = import ../modules/shared/import-hm.nix;
          sharedModules =
            [
              inputs.nixcord.homeModules.nixcord
              inputs.nixkit.homeModules.default
              inputs.spicetify-nix.homeManagerModules.default
            ]
            ++ extraHmModules;
        };
      }
    )
    (
      {vars, ...}: {
        home-manager.users.${vars.user.name} = import platformImport;
      }
    )
  ];
}
