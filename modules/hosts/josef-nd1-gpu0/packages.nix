{
  flake.modules.nixos.josef-nd1-gpu0 =
    # TODO: missing packages for josef-nd1-gpu0
    # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/507
    # - BeamMP
    # - audiorelay
    # - virtualhere
    # labels: os:nix
    {pkgs, ...}: {
      services.flatpak = {
        enable = false;
        packages = [
          # "com.geeks3d.furmark" # XWAYLAND GRRRR!!! (doesnt work)
        ];
      };
      environment.systemPackages = with pkgs; [
        nvtopPackages.full
      ];
    };
}
