{
  #TODO: CI test for external config (nix-work mock)
  #Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/505
  description = "ojsef39 dotfiles.nix configuration";
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz"; # latest unstable
    nixpkgs.url = "https://flakehub.com/f/JHOFER-Cloud/NixOS-nixpkgs/0.1.tar.gz"; # latest nixpkgs-unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*"; # latest stable release
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    # Recursively imports .nix files, paths containing `/_` are skipped.
    import-tree.url = "github:denful/import-tree";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs_fork = {
      url = "github:ojsef39/nixpkgs/feat/dadav-helm-schema";
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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release"; # Do not override its nixpkgs input, otherwise there can be mismatch between patches and kernel version
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixkit = {
      # url = "https://flakehub.com/f/JHOFER-Cloud/frostplexx-nixkit/0.1.tar.gz";
      url = "github:frostplexx/nixkit/feat/macmousefix";
      # url = "/Users/josefhofer/CodeProjects/github.com/frostplexx/nixkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agate = {
      url = "github:frostplexx/agate-wm";
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
    virtualhere = {
      url = "github:BatteredBunny/virtualhere-nixos";
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
    claude-code = {
      url = "github:sadjow/claude-code-nix?ref=latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned to 1.0.40; versions after this break MCP integration.
    nixpkgs-copilot-cli.url = "github:NixOS/nixpkgs/3df3d1dbd49472b0cb5b921ef9f3cab8ee39f5f6";
  };

  # Dendritic pattern: see README.md for the module aggregates this flake
  # publishes and how a downstream flake consumes them.
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
