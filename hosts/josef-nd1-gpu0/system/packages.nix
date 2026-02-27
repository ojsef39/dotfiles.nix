# TODO: missing packages for josef-nd1-gpu0
# Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/507
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
