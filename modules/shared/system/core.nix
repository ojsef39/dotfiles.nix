{
  pkgs,
  lib,
  vars,
  ...
}: let
  cachixHook = pkgs.callPackage ../../../packages/cachix-hook {
    ignorePatterns =
      ["source" "etc" "system" "home-manager" "user-environment" ".zip" vars.user.name]
      ++ (vars.cachix.ignorePatterns or []);
  };
in {
  nix = {
    enable = false;
    package = pkgs.nix;
  };
  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };
  determinateNix = {
    customSettings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = ["root" "@wheel" vars.user.name];
      extra-substituters =
        ["https://cache.nixos.org" "https://ojsef39.cachix.org" "https://nvf.cachix.org"]
        ++ lib.optionals (vars.cache.community or false) ["https://nix-community.cachix.org"];
      extra-trusted-substituters =
        ["https://cache.nixos.org" "https://ojsef39.cachix.org" "https://nvf.cachix.org"]
        ++ lib.optionals (vars.cache.community or false) ["https://nix-community.cachix.org"];
      extra-trusted-public-keys =
        ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "ojsef39.cachix.org-1:Pe8zOhPVMt4fa/2HYlquHkTnGX3EH7lC9xMyCA2zM3Y=" "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="]
        ++ lib.optionals (vars.cache.community or false) ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
      lazy-trees = true;
      extra-experimental-features = ["parallel-eval external-builders"];
      eval-cores = 0;
      post-build-hook = "${cachixHook}/bin/cachix-push-hook";
    };
  };

  # NOTE: Idk why this has to be set to 5
  system.stateVersion = 5;
}
