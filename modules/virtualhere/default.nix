{
  flake.modules.nixos.josef-nd1-gpu0 = {
    pkgs,
    config,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      virtualhere-client-gui
    ];

    programs.nix-ld.enable = true;

    boot.extraModulePackages = with config.boot.kernelPackages; [
      usbip
    ];
  };
}
