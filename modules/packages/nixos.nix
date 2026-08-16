{
  flake.modules.nixos.base = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      net-tools
      usbutils
      pciutils
    ];
  };
}
