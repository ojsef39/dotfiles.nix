{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nh
    podman
    podman-compose
    virt-viewer
    vscode
  ];
}
