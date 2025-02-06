{ pkgs, lib, vars, ... }: 
{
  environment.systemPackages = with pkgs; [
    podman
    virt-viewer
    podman-compose
    vscode
  ];
}
