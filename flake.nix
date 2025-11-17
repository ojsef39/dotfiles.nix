{
  description = "ojsef39 base nix configuration";
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz"; # latest unstable
    nixpkgs.url = "https://flakehub.com/f/JHOFER-Cloud/NixOS-nixpkgs/0.1.tar.gz"; # latest nixpkgs-unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs_fork = {
      url = "github:ojsef39/nixpkgs/mist";
      inputs.nixpkgs.follows = "nixpkgs";
      # url = "/Users/josefhofer/CodeProjects/github.com/ojsef39/nixpkgs";
      # url = "/Users/josefhofer/CodeProjects/github.com/ojsef39/nixpkgs";
    };
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.tar.gz"; # latest master
      # url = "/Users/josefhofer/CodeProjects/github.com/nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1.tar.gz"; # latest master
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
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
    # Fish 4.1.2 - workaround for completion bug in 4.2.x
    # See: https://github.com/NixOS/nixpkgs/issues/462025
    nixpkgs-fish = {
      url = "github:nixos/nixpkgs/fe9e07b2b565a8dee42e30eaff3e3606f6aefd6a";
    };
  };
  outputs = inputs @ {
    home-manager,
    neovim-nightly-overlay,
    nixcord,
    nixkit,
    nixpkgs,
    spicetify-nix,
    ...
  }: let
    # Helper to support all standard flake systems
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

    # Create an overlay that exposes packages with custom vars
    makeOverlay = vars: _final: prev:
      import ./packages {
        pkgs = prev;
        inherit vars;
      };
  in {
    sharedModules = [
      # Apply base packages overlay
      ({vars, ...}: {
        nixpkgs.overlays = [(makeOverlay vars)];
      })
      {
        nixpkgs.overlays = [
          nixkit.overlays.default
          neovim-nightly-overlay.overlays.default
          # ⬇️ Leave here as example for building from source instead of nixpkg repo:
          (_final: prev: {
            nh = inputs.nh.packages.${prev.system}.default;
            inherit (inputs.nixpkgs_fork.legacyPackages.${prev.system}) mist mist-cli;
            # renovate = inputs.nixpkgs_fork.legacyPackages.${prev.system}.renovate;
            # ⬇️ no idea why but it has to be done like this for unfree packages (inherit also inherits nixpkgs config?)
            # claude-code = prev.callPackage "${inputs.nixpkgs_claude_code_fork}/pkgs/by-name/cl/claude-code/package.nix" {};
            # Override fish to 4.1.2 - https://github.com/NixOS/nixpkgs/issues/462025
            inherit (inputs.nixpkgs-fish.legacyPackages.${prev.system}) fish fishPlugins;
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
              spicetify-nix.homeManagerModules.default
            ];
          };
        }
      )
      ./hosts/shared/import-sys.nix
    ];

    macModules = [
      inputs.determinate.darwinModules.default
      ./hosts/darwin/import.nix
      ./hosts/darwin/homebrew.nix
    ];

    # nixosModules = [
    #   inputs.determinate.nixosModules.default
    # ];

    # Library functions for consuming flakes
    lib = {
      # Create an overlay that exposes packages with custom vars
      # Usage: nixpkgs.overlays = [(base.lib.makeOverlay vars)];
      inherit makeOverlay;

      # Create packages output for all systems with custom vars
      # Usage: packages = base.lib.makePackages vars;
      makePackages = vars:
        forAllSystems (system: let
          pkgs = import nixpkgs {inherit system;};
        in
          import ./packages {
            inherit pkgs vars;
          });
    };
  };
}
