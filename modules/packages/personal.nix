{inputs, ...}: {
  flake.modules.generic.personal = {pkgs, ...}: let
    # TODO: use pkgs.coderabbit-cli once it is in nixpkgs (drop the flake input too)
    # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/2490
    inherit
      (import inputs.nixpkgs-coderabbit-cli {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      })
      coderabbit-cli
      ;
  in {
    environment.systemPackages = [
      (pkgs.callPackage ../../packages/coderabbit {inherit coderabbit-cli;})
    ];
  };
}
