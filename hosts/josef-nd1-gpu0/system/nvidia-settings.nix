{
  config,
  lib,
  pkgs,
  ...
}: {
  # Hardware configuration
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [pkgs.nvidia-vaapi-driver];
    };
    enableRedistributableFirmware = lib.mkDefault true; # needed for GPU Passthrough to work

    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = true;
      package = let
        fixPatch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/CachyOS/kernel-patches/master/6.19/misc/nvidia/0003-Fix-compile-for-6.19.patch";
          hash = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
        };
        base = config.boot.kernelPackages.nvidiaPackages.latest;
      in
        base
        // {
          open = base.open.overrideAttrs (old: {
            patches = (old.patches or []) ++ [fixPatch];
          });
        };
    };
  };

  # Enable NVIDIA drivers for X server
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  # Systemd service to configure NVIDIA GPU settings at boot
  systemd.services.nvidia-gpu-settings = {
    description = "Configure NVIDIA GPU settings (persistence, power limit, clock speed)";
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    path = [config.hardware.nvidia.package];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };

    script = ''
      # Enable persistence mode (keeps driver loaded)
      nvidia-smi -pm 1

      # Set power limit to 400W
      nvidia-smi -pl 400

      # Lock GPU clocks to 3090 MHz
      nvidia-smi -lgc 3090

      # Display current settings
      nvidia-smi
    '';
  };
}
