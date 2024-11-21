{ vars, pkgs, lib, ... }:
{
  imports =
    [
        ./apps.nix
        ./system.nix
        # ./host-users.nix
        ./stylix.nix
    ];
}
