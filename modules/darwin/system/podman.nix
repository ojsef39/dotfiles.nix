{
  pkgs,
  vars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    podman-mac-helper
    (writeShellScriptBin "docker" ''exec ${podman}/bin/podman "$@"'')
  ];

  system.activationScripts.podmanMacHelper.text = ''
    helper_plist="/Library/LaunchDaemons/com.github.containers.podman.helper-${vars.user.name}.plist"
    if [ ! -f "$helper_plist" ]; then
      echo "Installing podman-mac-helper..."
      ${pkgs.podman-mac-helper}/bin/podman-mac-helper install
    fi
  '';
}