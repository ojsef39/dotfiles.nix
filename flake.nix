{
  description = "ojsef39 base nix configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_fork = {
      url = "github:ojsef39/nixpkgs/nixos-unstable";
      # url = "/Users/josefhofer/CodeProjects/github.com/ojsef39/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixkit = {
      url = "github:frostplexx/nixkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ⬇️ Leave here as example for building from source instead of nixpkg repo:
    # nh = {
    #   url = "github:viperml/nh";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs = inputs @ { self, nixpkgs, home-manager, darwin, nixcord, nixkit, ... }:
  # ⬇️ Leave here as example for building from source instead of nixpkg repo:
  let
    overlays = [
      (final: prev: {
        # nh = inputs.nh.packages.${prev.system}.default;
        renovate = inputs.nixpkgs_fork.legacyPackages.${prev.system}.renovate;
      })
    ];
  in
  {
    sharedModules = [
      ./nix/core.nix
      { nixpkgs.overlays = overlays; } # Leave here as example for building from source instead of nixpkg repo:
      home-manager.darwinModules.home-manager
      nixkit.darwinModules.default
      ({ vars, system, ... }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = { inherit vars inputs; };
          users.${vars.user.name} = import ./hosts/shared/import-hm.nix;
          sharedModules = [
            nixcord.homeModules.nixcord
            nixkit.homeModules.default
          ];
        };
      })
      ./hosts/shared/import-sys.nix
    ];

    macModules = [
      ./hosts/darwin/import.nix
      ./hosts/darwin/homebrew.nix
    ];
  };
}
