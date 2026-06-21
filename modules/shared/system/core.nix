{
  pkgs,
  lib,
  vars,
  ...
}: let
  cachixHook = pkgs.callPackage ../../../packages/cachix-hook {
    inherit vars;
    ignorePatterns =
      [
        "source"
        "etc"
        "system"
        "home-manager"
        "user-environment"
        ".zip"
        vars.user.name
      ]
      ++ (vars.cachix.ignorePatterns or []);
  };
in {
  _module.args.nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
      vars.user.name
    ];
    extra-substituters =
      [
        "https://cache.nixos.org"
        "https://ojsef39.cachix.org"
        "https://nixkit.cachix.org"
        "https://nvf.cachix.org"
      ]
      ++ lib.optionals (vars.cache.community or false) [
        "https://nix-community.cachix.org"
        "https://claude-code.cachix.org"
      ];
    extra-trusted-substituters =
      [
        "https://cache.nixos.org"
        "https://ojsef39.cachix.org"
        "https://nixkit.cachix.org"
        "https://nvf.cachix.org"
      ]
      ++ lib.optionals (vars.cache.community or false) [
        "https://nix-community.cachix.org"
        "https://claude-code.cachix.org"
      ];
    extra-trusted-public-keys =
      [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ojsef39.cachix.org-1:Pe8zOhPVMt4fa/2HYlquHkTnGX3EH7lC9xMyCA2zM3Y="
        "nixkit.cachix.org-1:d3yhZjbGSL6QTgzZsxE3lRLIQ8jGmH7/XxiD/5hGmfA="
        "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
      ]
      ++ lib.optionals (vars.cache.community or false) [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      ];
    lazy-trees = true;
    extra-experimental-features = ["parallel-eval external-builders"];
    eval-cores = 0;
    # TODO: drop the darwin guard once nixpkgs ships a libffi that works on macOS 26
    # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/1439
    #   https://github.com/NixOS/nixpkgs/pull/354108  (libffi-mit -> libffi-apple, the regression)
    #   https://github.com/libffi/libffi/pull/621     (upstream Apple trampoline fix)
    post-build-hook = lib.optionalString (!pkgs.stdenv.isDarwin) "${cachixHook}/bin/cachix-push-hook";
  };

  nixpkgs.config = {
    allowBroken = false;
    allowUnfree = true;
    # Eval-only leak from nixpkgs writers/scripts.nix:1202 forcing pkgs.pypy2Packages.
    # Not in any built closure; fix in flight via nixpkgs#516241. Drop when nixpkgs bumps past that.
    permittedInsecurePackages = [
      "pypy2.7-setuptools-44.0.0"
      "pypy2.7-pip-20.3.4"
    ];
  };
}
