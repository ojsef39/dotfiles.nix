# Opt-in capability: not in `nixos.base`, a host imports it explicitly.
# Driver config is card-agnostic; per-card tuning hangs off a `gpuType.<card>`
# toggle so another Nvidia machine reuses this and picks its own profile.
{
  flake.modules.nixos.nvidia = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.gpuType = {
      rtx4080 = lib.mkEnableOption "RTX 4080 power and clock tuning";
    };

    config = {
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
          package = config.boot.kernelPackages.nvidiaPackages.latest;
        };
      };

      # Enable NVIDIA drivers for X server
      services.xserver = {
        enable = true;
        videoDrivers = ["nvidia"];
      };

      # Systemd service to configure NVIDIA GPU settings at boot
      systemd.services.nvidia-gpu-settings = lib.mkIf config.gpuType.rtx4080 {
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
    };
  };
}
