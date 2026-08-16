{
  flake.modules.generic.personal = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [];
  };
}
