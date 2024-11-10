{ pkgs, lib, vars, ... }: 
{
  environment.systemPackages = with pkgs; [
    # CLI utilities
    # _1password-cli  # Password manager
    act
    aichat
    btop
    fastfetch
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
    discord         ##TODO: Add vencord
    obsidian        # Note-taking
    raycast         # Spotlight replacement
    stats
    utm             # Virtualization
  ];
}
