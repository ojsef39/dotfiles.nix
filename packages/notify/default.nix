{pkgs}: {
  send-cooking = pkgs.callPackage ./send-cooking.nix {};
  send-away = pkgs.callPackage ./send-away.nix {};
}
