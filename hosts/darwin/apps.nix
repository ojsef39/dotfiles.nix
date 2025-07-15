{ pkgs, lib, vars, ... }: 
{
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
    neovide
    nmap
    progress
    python3Full
    retry
    rsync
    speedtest-cli
    wget
    whois
    yamllint

    # GUI Applications
    obsidian        # Note-taking
    stats
    utm             # Virtualization
  ];
}
