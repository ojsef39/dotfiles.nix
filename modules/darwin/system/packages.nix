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
    kubeconform
    kubectl
    kustomize
    mist-cli
    ncdu
    neovide
    nmap
    progress
    python3
    retry
    rsync
    speedtest-cli
    wget
    whois
    yamllint

    # GUI Applications
    mist
    obsidian # Note-taking
    stats
    utm # Virtualization
  ];
}
