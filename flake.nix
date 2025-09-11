{
  description = "ojsef39 base nix configuration";
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz"; # latest unstable
    nixpkgs.url = "https://flakehub.com/f/JHOFER-Cloud/NixOS-nixpkgs/0.1.tar.gz"; # latest nixpkgs-unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs_fork = {
    #   url = "github:ojsef39/nixpkgs/nixos-unstable";
    #   # url = "/Users/josefhofer/CodeProjects/github.com/ojsef39/nixpkgs";
    # };
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.tar.gz"; # latest master
      # url = "/Users/josefhofer/CodeProjects/github.com/nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1.tar.gz"; # latest master
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixkit = {
      url = "https://flakehub.com/f/JHOFER-Cloud/frostplexx-nixkit/0.1.tar.gz";
      # url = "github:ojsef39/nixkit";
      # url = "/Users/josefhofer/CodeProjects/github.com/frostplexx/nixkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ⬇️ Leave here as example for building from source instead of nixpkg repo:
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    home-manager,
    neovim-nightly-overlay,
    nixcord,
    nixkit,
    ...
  }: {
    sharedModules = [
      {
        nixpkgs.overlays = [
          nixkit.overlays.default
          neovim-nightly-overlay.overlays.default
          # ⬇️ Leave here as example for building from source instead of nixpkg repo:
          (_final: prev: {
            nh = inputs.nh.packages.${prev.system}.default;
            # renovate = inputs.nixpkgs_fork.legacyPackages.${prev.system}.renovate;
          })
        ];
      }
      ./nix/core.nix
      home-manager.darwinModules.home-manager
      nixkit.darwinModules.default
      (
        {vars, ...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {inherit vars inputs;};
            users.${vars.user.name} = import ./hosts/shared/import-hm.nix;
            sharedModules = [
              nixcord.homeModules.nixcord
              nixkit.homeModules.default
            ];
          };
        }
      )
      ./hosts/shared/import-sys.nix
    ];

    macModules = [
      ./hosts/darwin/import.nix
      ./hosts/darwin/homebrew.nix
    ];
  };
}
