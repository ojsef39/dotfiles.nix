{
  flake.modules.nixos.cachyos-kernel = {
    inputs,
    pkgs,
    lib,
    ...
  }: {
    nix.settings = {
      extra-substituters = [
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
      ];
      extra-trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
    nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
    # force override the default kernel package, if this file is imported its probably wanted
    boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;

    # NOTE: below might make sense for bare metal, in VMs it actually makes performance worse
    # when creating modules for this, there should probably be a isVM flag to disable this
    # ADIOS IO Scheduler (CachyOS kernel — not in nixpkgs enum, use udev directly)
    # https://wiki.cachyos.org/configuration/general_system_tweaks/#adios-io-scheduler
    # services.udev.extraRules = ''
    #   ACTION=="add|change", KERNEL=="sd[a-z]*|vd[a-z]*|nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="adios"
    # '';
    # services.scx = {
    #   enable = true;
    #   # https://wiki.cachyos.org/configuration/sched-ext/#scheduler-guide-profiles-and-use-cases
    #   scheduler = "scx_lavd";
    #   extraArgs = ["--performance"];
    # };
  };
}
