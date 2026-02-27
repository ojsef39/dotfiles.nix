{pkgs, ...}: {
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
    claude-vm
    devenv
    fh
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
    nh
    nix-init # https://github.com/nix-community/nix-init
    nix-output-monitor
    nix-tree
    nix-update # https://github.com/Mic92/nix-update
    nixpkgs-review
    nmap
    podman
    podman-compose
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
