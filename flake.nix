{
  description = "ojsef39 base nix configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # yuki = {
    #   url = "github:frostplexx/yuki";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ { self, nixpkgs, home-manager, darwin, ... }: # yuki,
  {
    sharedModules = [
      ./nix/core.nix
      home-manager.darwinModules.home-manager
      yuki.nixosModules.default
      ({ vars, system, ... }: {  # system is now available here
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = { inherit vars inputs; };
          users.${vars.user} = import ./hosts/shared/import-hm.nix;
          sharedModules = [
            inputs.nixcord.homeManagerModules.nixcord
          ];
        };
      })
      ./hosts/shared/import-sys.nix
    ];

    macModules = [
      inputs.stylix.darwinModules.stylix
      ./hosts/darwin/import.nix
      ./hosts/darwin/homebrew.nix
    ];
  };
}
