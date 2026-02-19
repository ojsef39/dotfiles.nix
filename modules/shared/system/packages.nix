{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # packages from pkgs folder
    kubectl-debug

    # Nix tools #
    cachix
    devenv
    fh
    nh
    nix-init # https://github.com/nix-community/nix-init
    nix-output-monitor
    nix-tree
    nix-update # https://github.com/Mic92/nix-update
    nixpkgs-review
    update-nix-fetchgit # https://github.com/expipiplus1/update-nix-fetchgit
    ##
    _1password-cli
    _1password-gui
    act
    btop
    gh
    gh-dash
    gh-poi
    ghq
    gitlab-ci-local
    go
    gomplate
    helm-schema-gen
    hwatch
    just
    kubeconform
    kubectl
    kustomize
    minikube
    ncdu
    neovide
    nmap
    podman
    podman-compose
    progress
    python3
    retry
    rsync
    speedtest-cli
    virt-viewer
    wget
    whois
  ];
}
