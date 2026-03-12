#TODO: Loonix
#Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/515
# - [x] Remove x86_64-darwin support
# - [x] Add basic nixos support
# - [ ] btw plasma graphisch konfigurieren und dann einfach nix run github:nix-community/plasma-manager machen und das spuckt dann eine config aus
# - [ ] Check if everything that should be shared is actually shared (and not duplicated in both mac and nixos config)
#  - [ ] !! USE hosts/_personal DONT POLLUTE WORK MACHINES USING EXPOSED MODULES
#  - [!] https://github.com/niri-wm/niri -> doesnt work with sunshine https://github.com/niri-wm/niri/discussions/714
#  - [x] Hyperland + https://github.com/caelestia-dots/shell
#  - [?] Try to recreate bazzite?
#  - [x] Use cachy kernel
#  - [ ] https://github.com/kimjongbing/nix-proton-cachyos (https://reddit.com/r/cachyos/comments/1rdsxk1/_/o77l4f7/?context=1)
#  - [ ] https://github.com/beeradmoore/dlss-swapper / https://wiki.cachyos.org/configuration/gaming/#forcing-the-latest-dlss-preset
# - [ ] give github stars to whatever i used
# - [x] CI
# - [ ] Docs
# - [ ] Rework keybinds (use heyperkey on mac, look at https://wiki.hypr.land/Configuring/Binds/#keysym-combos for linux)
# labels: enhancement, os:nix
{
  #TODO: CI test for external config (nix-work mock)
  #Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/505
  description = "ojsef39 dotfiles.nix configuration";
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz"; # latest unstable
    nixpkgs.url = "https://flakehub.com/f/JHOFER-Cloud/NixOS-nixpkgs/0.1.tar.gz"; # latest nixpkgs-unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*"; # latest stable release
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs-25.url = "github:nixos/nixpkgs/release-25.05"; # specific 25.x release
    nixpkgs_fork = {
      url = "github:ojsef39/nixpkgs/mist";
      inputs.nixpkgs.follows = "nixpkgs";
      # url = "/Users/josefhofer/CodeProjects/github.com/ojsef39/nixpkgs";
      # url = "/Users/josefhofer/CodeProjects/github.com/ojsef39/nixpkgs";
    };
    nixpkgs_fork2 = {
      url = "github:ojsef39/nixpkgs/feat/dadav-helm-schema";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release"; # Do not override its nixpkgs input, otherwise there can be mismatch between patches and kernel version
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      # inputs.nixpkgs.follows = "nixpkgs";
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
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    # ⬇️ Leave here as example for building from source instead of nixpkg repo:
    # nh = {
    #   url = "github:nix-community/nh";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-vm = {
      url = "github:ojsef39/claude-vm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };
  outputs = inputs @ {
    self,
    home-manager,
    nixkit,
    nixpkgs,
    darwin,
    caelestia-shell,
    ...
  }: let
    # Library functions for consuming flakes
    myLib = import ./lib {inherit (nixpkgs) lib;};
    supportedSystems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
    forSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    # Shared overlays and nix module — platform-agnostic, consumed by both macModules and nixosModules
    sharedModules = [
      # Apply base packages overlay
      (
        {vars, ...}: {
          nixpkgs.overlays = [(myLib.makeOverlay vars)];
        }
      )
      {
        nixpkgs.overlays = [
          nixkit.overlays.default
          (
            _final: prev:
            #   let
            #   pkgs-25 = import inputs.nixpkgs-25 {
            #     inherit (prev.stdenv.hostPlatform) system;
            #     config.allowUnfree = true;
            #   };
            # in
            {
              # ⬇️ Leave here as example for building from source instead of nixpkg repo:
              # nh = inputs.nh.packages.${prev.stdenv.hostPlatform.system}.default;
              claude-vm = inputs.claude-vm.packages.${prev.stdenv.hostPlatform.system}.default;
              inherit (inputs.nixpkgs_fork.legacyPackages.${prev.stdenv.hostPlatform.system}) mist mist-cli;
              inherit (inputs.nixpkgs_fork2.legacyPackages.${prev.stdenv.hostPlatform.system}) helm-schema-gen;
              # renovate = inputs.nixpkgs_fork.legacyPackages.${prev.stdenv.hostPlatform.system}.renovate;
              # ⬇️ no idea why but it has to be done like this for unfree packages (inherit also inherits nixpkgs config?)
              # claude-code = prev.callPackage "${inputs.nixpkgs_claude_code_fork}/pkgs/by-name/cl/claude-code/package.nix" {};
              # inherit (pkgs-25) vesktop;
            }
          )
        ];
      }
      ./modules/shared/import-sys.nix
    ];

    macModules =
      [
        inputs.determinate.darwinModules.default
        ./modules/darwin/import-sys.nix
      ]
      ++ myLib.mkHomeManagerModules {
        hmModule = home-manager.darwinModules.home-manager;
        nixkitModule = nixkit.darwinModules.default;
        platformImport = ./modules/darwin/import-hm.nix;
        inherit inputs;
        baseLib = myLib;
      };

    linuxModules =
      [
        inputs.determinate.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
        ./modules/nixos/import-sys.nix
      ]
      ++ myLib.mkHomeManagerModules {
        hmModule = home-manager.nixosModules.home-manager;
        nixkitModule = nixkit.nixosModules.default;
        platformImport = ./modules/nixos/import-hm.nix;
        extraHmModules = [caelestia-shell.homeManagerModules.default];
        inherit inputs;
        baseLib = myLib;
      };

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

    # NixOS — josef-nd1-gpu0
    nixosConfigurations = let
      name = "josef-nd1-gpu0";
    in {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          self.sharedModules
          ++ self.linuxModules
          ++ [
            {networking.hostName = name;}
            ./hosts/josef-nd1-gpu0/import-sys.nix
            (
              {vars, ...}: {
                home-manager.users.${vars.user.name} = import ./hosts/josef-nd1-gpu0/import-hm.nix;
              }
            )
          ];
        specialArgs = {
          vars = import ./vars/personal.nix;
          baseLib = myLib;
          inherit inputs;
        };
      };
    };

    lib = myLib;

    packages = forSystems (system:
      import ./packages {
        pkgs = nixpkgs.legacyPackages.${system};
      });

    devShells = forSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      md-build = pkgs.writeShellScriptBin "md-build" ''
        ${pkgs.mdbook}/bin/mdbook build wiki
      '';

      md-serve = pkgs.writeShellScriptBin "md-serve" ''
        ${pkgs.mdbook}/bin/mdbook serve wiki
      '';
    in {
      default = pkgs.mkShell {
        packages = [
          pkgs.mdbook
          md-build
          md-serve
        ];
      };
    });

    formatter = forSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
