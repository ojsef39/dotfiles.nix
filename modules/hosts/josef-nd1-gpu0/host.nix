{
  flake.modules.nixos.josef-nd1-gpu0 = {pkgs, ...}: {
    # Bootloader (UEFI — systemd-boot)
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi = {
          canTouchEfiVariables = true;
        };
      };
      kernelPackages = pkgs.linuxPackages;
      kernelParams = ["tsc=reliable" "clocksource=tsc"];
    };

    # Mount Games disk (removable)
    fileSystems."/mnt/games" = {
      device = "/dev/disk/by-uuid/05cdf8fa-54ca-4a38-9a91-34c7905ff8fc";
      fsType = "ext4";
      options = [
        "nofail" # Don't fail boot if disk is missing
        "x-systemd.device-timeout=5" # Only wait 5 seconds for disk
      ];
    };

    networking = {
      networkmanager.enable = true;
      firewall.allowedUDPPorts = [9]; # WoL UDP port
      interfaces.ens18.wakeOnLan.enable = true;
    };
    powerManagement.enable = true;

    security.rtkit.enable = true;

    #FIX: is this correct to disable sleeping etc??
    # labels: os:nix
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    services = {
      logind.settings = {
        Login = {
          IdleAction = "ignore";
          IdleActionSec = 0;
        };
      };
      qemuGuest.enable = true;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      printing.enable = true;
    };

    system.stateVersion = "25.11";
  };
}
