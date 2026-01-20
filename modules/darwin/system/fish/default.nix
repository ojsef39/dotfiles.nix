_: {
  # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you
  # will also want to enable the fish shell in /etc/nixos/configuration.nix:
  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
}
