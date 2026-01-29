{
  description = "ojsef39 dotfiles.nix configuration";
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz"; # latest unstable
    nixpkgs.url = "https://flakehub.com/f/JHOFER-Cloud/NixOS-nixpkgs/0.1.tar.gz"; # latest nixpkgs-unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
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
    nvf = {
      url = "github:notashelf/nvf";
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
    # nh = {
    #   url = "github:nix-community/nh";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs = inputs @ {
    self,
    home-manager,
    nixcord,
    nixkit,
    nixpkgs,
    spicetify-nix,
    darwin,
    ...
  }: let
    # Library functions for consuming flakes
    myLib = import ./lib {
      inherit (nixpkgs) lib;
      inherit nixpkgs;
    };
  in {
    # Export base modules for nix-work to consume (same pattern as before migration)
    sharedModules = [
      # Apply base packages overlay
      ({vars, ...}: {
        nixpkgs.overlays = [(myLib.makeOverlay vars)];
      })
      {
        nixpkgs.overlays = [
          nixkit.overlays.default
          # ⬇️ Leave here as example for building from source instead of nixpkg repo:
          (_final: prev: {
            # nh = inputs.nh.packages.${prev.stdenv.hostPlatform.system}.default;
            inherit (inputs.nixpkgs_fork.legacyPackages.${prev.stdenv.hostPlatform.system}) mist mist-cli;
            # renovate = inputs.nixpkgs_fork.legacyPackages.${prev.stdenv.hostPlatform.system}.renovate;
            # ⬇️ no idea why but it has to be done like this for unfree packages (inherit also inherits nixpkgs config?)
            # claude-code = prev.callPackage "${inputs.nixpkgs_claude_code_fork}/pkgs/by-name/cl/claude-code/package.nix" {};
            inherit
              (inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system})
              vesktop
              firefox
              firefox-unwrapped
              ;
          })
        ];
      }
      ./modules/shared/import-sys.nix
      home-manager.darwinModules.home-manager
      nixkit.darwinModules.default
      (
        {vars, ...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit vars inputs;
              baseLib = myLib;
            };
            users.${vars.user.name} = import ./modules/shared/import-hm.nix;
            sharedModules = [
              nixcord.homeModules.nixcord
              nixkit.homeModules.default
              spicetify-nix.homeManagerModules.default
            ];
          };
        }
      )
    ];

    macModules = [
      inputs.determinate.darwinModules.default
      ./modules/darwin/import-sys.nix
      (
        {vars, ...}: {
          home-manager.users.${vars.user.name} = import ./modules/darwin/import-hm.nix;
        }
      )
    ];

    # Personal macOS configuration
    darwinConfigurations.mac = darwin.lib.darwinSystem {
      modules =
        self.sharedModules
        ++ self.macModules
        ++ [
          {nixpkgs.hostPlatform = "aarch64-darwin";}
          # Personal configuration (recursive discovery via hosts/mac/import-sys.nix)
          ./hosts/mac/import-sys.nix
          (
            {vars, ...}: {
              home-manager.users.${vars.user.name} = import ./hosts/mac/import-hm.nix;
            }
          )
        ];
      specialArgs = {
        vars = import ./vars/personal.nix;
        baseLib = myLib;
      };
    };

    lib = myLib;

    packages = let
      mkPackages = system:
        import ./packages {
          pkgs = nixpkgs.legacyPackages.${system};
        };
    in {
      aarch64-darwin = mkPackages "aarch64-darwin";
      x86_64-darwin = mkPackages "x86_64-darwin";
      x86_64-linux = mkPackages "x86_64-linux";
    };
  };
}
