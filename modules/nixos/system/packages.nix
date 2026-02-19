{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    net-tools
    usbutils
    pciutils
  ];
}
