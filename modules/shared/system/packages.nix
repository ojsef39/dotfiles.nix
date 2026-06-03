{pkgs, ...}: let
  helm-with-plugins = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      pkgs.helm-schema-gen
      pkgs.kubernetes-helmPlugins.helm-unittest
    ];
  };
in {
  environment.systemPackages = with pkgs; [
    # packages from pkgs folder
    kubectl-debug

    # Nix tools #
    ##
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
    gomplate
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
    nix-output-monitor
    nix-tree
    nix-update # https://github.com/Mic92/nix-update
    nixpkgs-review
    nmap
    progress
    python3
    retry
    rsync
    speedtest-cli
    update-nix-fetchgit # https://github.com/expipiplus1/update-nix-fetchgit
    virt-viewer
    wget
    whois
  ];
}
