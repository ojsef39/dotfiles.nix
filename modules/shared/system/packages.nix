{pkgs, ...}: let
  # nixpkgs only ships `untt`, but plugin.yaml expects untt-<os>-<arch> — symlink them.
  helm-unittest = pkgs.kubernetes-helmPlugins.helm-unittest.overrideAttrs (old: {
    postInstall =
      old.postInstall
      + ''
        for bin in untt-linux-amd64 untt-linux-arm64 untt-macos-amd64 untt-macos-arm64; do
          ln -s untt $out/helm-unittest/$bin
        done
      '';
  });
  helm-with-plugins = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      helm-unittest
      pkgs.helm-docs
      pkgs.helm-schema-gen
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
    nurl
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
