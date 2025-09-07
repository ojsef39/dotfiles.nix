{
  pkgs,
  lib,
  vars,
  ...
}: let
  cachixHook = pkgs.writeScript "cachix-push-hook" ''
    #!/bin/bash
    set -e
    CACHIX_NAME="ojsef39"
    IGNORE_PATTERNS="${lib.concatStringsSep " " (["source" "etc" "darwin-system"] ++ (vars.cachix.ignorePatterns or []))}"

    # Filter out ignored patterns
    FILTERED_PATHS=""
    for path in $OUT_PATHS; do
      # Check if path should be ignored
      should_ignore=false
      if [[ -n "$IGNORE_PATTERNS" ]]; then
        IFS=' ' read -ra PATTERN_ARRAY <<< "$IGNORE_PATTERNS"
        for pattern in "''${PATTERN_ARRAY[@]}"; do
          if [[ -n "$pattern" && "$path" == *"$pattern"* ]]; then
            should_ignore=true
            break
          fi
        done
      fi

      if [[ "$should_ignore" == "false" ]]; then
        FILTERED_PATHS="$FILTERED_PATHS $path"
      fi
    done

    if [ -z "$FILTERED_PATHS" ]; then
      echo "Nothing to push"
      exit 0
    fi

    # Read cachix token from user's config file
    echo "Authenticating with cachix..."
    CACHIX_CONFIG="/Users/${vars.user.name}/.config/cachix/cachix.dhall"
    if [ -f "$CACHIX_CONFIG" ]; then
      TOKEN=$(awk '/authToken/{getline; gsub(/[" ]/, ""); print}' "$CACHIX_CONFIG")
      echo "$TOKEN" | ${pkgs.cachix}/bin/cachix authtoken --stdin
    else
      echo "No cachix config found at $CACHIX_CONFIG"
      echo "Run 'cachix_login' first to authenticate"
      exit 1
    fi

    ${pkgs.cachix}/bin/cachix push $CACHIX_NAME $FILTERED_PATHS
  '';
in {
  nix = {
    enable =
      if pkgs.stdenv.isDarwin
      then false
      else true;
    settings = {
      lazy-trees = true;
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [
        # "https://nix-community.cachix.org"
        "https://ojsef39.cachix.org"
      ];
      extra-trusted-substituters = [
        # "https://nix-community.cachix.org"
        "https://ojsef39.cachix.org"
      ];
      extra-trusted-public-keys = [
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ojsef39.cachix.org-1:Pe8zOhPVMt4fa/2HYlquHkTnGX3EH7lC9xMyCA2zM3Y="
      ];
    };
    package = pkgs.nix;
  };
  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  environment.etc."nix/nix.custom.conf" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      # Written by base/nix/core.nix
      extra-substituters = https://ojsef39.cachix.org
      extra-trusted-substituters = https://ojsef39.cachix.org
      extra-trusted-public-keys = ojsef39.cachix.org-1:Pe8zOhPVMt4fa/2HYlquHkTnGX3EH7lC9xMyCA2zM3Y=
      lazy-trees = true
      extra-experimental-features = parallel-eval
      eval-cores = 0
      post-build-hook = ${cachixHook}
    '';
  };

  # TODO: Idk why this has to be set to 5
  system.stateVersion = 5;
}
