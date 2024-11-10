{
  description = "ojsef39 base nix configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    darwin.url = "github:lnl7/nix-darwin/master";
    yuki.url = "github:frostplexx/yuki";
  };
  outputs = inputs @ { self, nixpkgs, home-manager, darwin, yuki, ... }:
  {
    sharedModules = [
      ./nix/core.nix
##TODO: Do i need homemanager again here or is it sufficient if its called by the parent?
      home-manager.darwinModules.home-manager
      ({ vars, system, ... }: {  # system is now available here
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = { inherit vars inputs; };
          users.${vars.user} = import ./hosts/shared/import.nix;
        };
        environment.systemPackages = [ yuki.packages.${system.darwin.aarch}.default ];
      })
      ({ config, pkgs, ... }: {
        nixpkgs.config.allowUnfree = true;
      })
    ];

    macModules = [
      home-manager.darwinModules.home-manager
      ./hosts/darwin/import.nix
      ./hosts/darwin/homebrew.nix
    ];
  };
}
