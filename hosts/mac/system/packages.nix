{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Personal packages
    fluxcd
    gemini-cli
    # wireshark # broken
    ## media stuff
    yt-dlp
    moonlight-qt
    # packages from base
    kubectl-debug
  ];
}
