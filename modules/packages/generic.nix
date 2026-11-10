{inputs, ...}: {
  flake.modules.generic.base = {pkgs, ...}: let
    rom = inputs.rom.packages.${pkgs.stdenv.hostPlatform.system}.default;
    helm-with-plugins = pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = [
        pkgs.kubernetes-helmPlugins.helm-unittest
        pkgs.helm-docs
        pkgs.helm-schema-dadav
      ];
    };
  in {
    environment.systemPackages = with pkgs; [
      # packages from pkgs folder
      kubectl-debug

      _1password-cli
      _1password-gui
      act
      btop
      cachix
      devenv
      fh
      gh
      gh-dash
      gh-poi
      ghq
      gitlab-ci-local
      go
      helm-with-plugins
      hwatch
      just
      kubeconform
      kubectl
      kustomize
      minikube
      ncdu
      neovide
      nh
      nix-init # https://github.com/nix-community/nix-init
      nix-tree
      nix-update # https://github.com/Mic92/nix-update
      nixpkgs-review
      nmap
      nurl
      progress
      psleep
      python3
      renovate # nixkit's renovate-jhc (JHOFER-Cloud fork), see flake.nix overlay
      retry
      rom # https://github.com/manic-systems/rom (nix output monitor)
      rsync
      speedtest-cli
      timer
      virt-viewer
      wget
      whois
    ];
  };
}
