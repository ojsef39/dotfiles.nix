{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Nix tools #
    nh
    nix-init # https://github.com/nix-community/nix-init
    nix-update # https://github.com/Mic92/nix-update
    nixpkgs-review
    update-nix-fetchgit # https://github.com/expipiplus1/update-nix-fetchgit
    ##
    direnv
    just
    podman
    podman-compose
    virt-viewer
    vscode
  ];
}
