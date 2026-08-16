{
  flake.modules.darwin.mac = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Personal packages
      fluxcd
      gemini-cli
      # wireshark # broken
      ## media stuff
      yt-dlp
      moonlight-qt
    ];
  };
}
