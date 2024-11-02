{
  description = "ojsef39 base nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager }: {
    sharedModuls = {};
    macModules = {};
    linuxModules = {};
    };
  };
}
