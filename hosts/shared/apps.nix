{ pkgs, lib, vars, ... }: 
{
  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    vscode
  ];
}
