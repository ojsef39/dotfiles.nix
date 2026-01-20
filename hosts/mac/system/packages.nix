{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Personal packages
    fluxcd
    # wireshark # broken
    ## media stuff
    yt-dlp
    moonlight-qt
    # packages from base
    kubectl-debug
  ];
}
