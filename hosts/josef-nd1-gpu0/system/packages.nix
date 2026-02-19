# TODO: missing packages for josef-nd1-gpu0
# - BeamMP
# - audiorelay
# - vierualhere
# labels: os:nix
{pkgs, ...}: {
  services.flatpak = {
    enable = true;
    packages = [
      "com.geeks3d.furmark"
    ];
  };
  environment.systemPackages = with pkgs; [
    nvtopPackages.full
  ];
}
