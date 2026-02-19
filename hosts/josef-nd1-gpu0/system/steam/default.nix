{
  config,
  lib,
  ...
}: {
  programs.steam.enable = true;

  # Override graphics to use NVIDIA's pre-built 32-bit libraries (avoids Mesa entirely)
  hardware.graphics.package32 = config.boot.kernelPackages.nvidiaPackages.latest.lib32;
  # Disable 32-bit ALSA support to avoid PyPy evaluation errors in i686 pipewire
  # Modern games (especially via Proton) use 64-bit audio anyway
  services.pipewire.alsa.support32Bit = lib.mkForce false;
  # services.pulseaudio.support32Bit = lib.mkForce false; # this not needed for some reason even tho the module also enables it
}
