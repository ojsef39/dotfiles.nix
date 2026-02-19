{
  pkgs,
  lib,
  ...
}: {
  # Enables vendor fish completions from nixpkgs.
  # useBabelfish translates bash activation scripts to fish on darwin.
  programs.fish = {
    enable = true;
    useBabelfish = lib.mkIf pkgs.stdenv.isDarwin true;
  };
}
