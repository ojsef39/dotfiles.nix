{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # CLI utilities
    # _1password-cli  # Password manager
    act
    aichat
    btop
    cargo
    container
    gh
    gh-dash
    gh-poi
    ghq
    gitlab-ci-local
    go
    gomplate
    hwatch
    kubectl
    kustomize
    kubeconform
    neovide
    nmap
    progress
    python3Full
    retry
    rsync
    speedtest-cli
    wget
    ncdu
    whois
    yamllint

    # GUI Applications
    obsidian # Note-taking
    stats
    utm # Virtualization
  ];
}
