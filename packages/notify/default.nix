{pkgs}: {
  send-cooking = pkgs.callPackage ./send-cooking.nix {};
  send-away = pkgs.callPackage ./send-away.nix {};
  rex-track = pkgs.callPackage ./rex-track.nix {};
  rex-k9s = pkgs.callPackage ./rex-k9s.nix {};
}
