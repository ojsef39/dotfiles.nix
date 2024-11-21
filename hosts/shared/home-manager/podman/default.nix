{pkgs, vars, ...}:
{
  home = {
    packages = with pkgs; [
      podman
      podman-compose
      podman-desktop
    ];
    activation = {
      podmanSetupBase = ''
        if ! /etc/profiles/per-user/${vars.user}/bin/podman machine ls --format "{{.Name}}" | grep -q "podman-machine-default"; then
          echo "No default podman machine found, initializing one..."
          /etc/profiles/per-user/${vars.user}/bin/podman  machine init
        fi
        if ! /etc/profiles/per-user/${vars.user}/bin/podman machine ls --format "{{.Running}}" | grep -q "true"; then
          /etc/profiles/per-user/${vars.user}/bin/podman machine start
        else
          echo "Default podman machine is already running."
        fi
      '';
    };
  };
}
