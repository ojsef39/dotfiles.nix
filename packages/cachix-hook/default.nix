{
  pkgs,
  cachixName ? "ojsef39",
  ignorePatterns ? [],
  vars,
}:
pkgs.writeShellApplication {
  name = "cachix-push-hook";
  runtimeInputs = [pkgs.cachix pkgs.gawk];
  text = ''
    set -e
    CACHIX_NAME="${cachixName}"
    IGNORE_PATTERNS="${pkgs.lib.concatStringsSep " " ignorePatterns}"

    # Filter paths if patterns specified
    FILTERED_PATHS=()
    for path in $OUT_PATHS; do
      should_ignore=false
      if [[ -n "$IGNORE_PATTERNS" ]]; then
        for pattern in $IGNORE_PATTERNS; do
          if [[ -n "$pattern" && "$path" == *"$pattern"* ]]; then
            should_ignore=true
            break
          fi
        done
      fi
      if [[ "$should_ignore" == "false" ]]; then
        FILTERED_PATHS+=("$path")
      fi
    done

    if [[ ''${#FILTERED_PATHS[@]} -eq 0 ]]; then
      echo "Nothing to push"
      exit 0
    fi

    CACHIX_CONFIG="/Users/${vars.user.name}/.config/cachix/cachix.dhall"
    if [[ -f "$CACHIX_CONFIG" ]]; then
      TOKEN=$(awk '/authToken/{getline; gsub(/[" ]/, ""); print}' "$CACHIX_CONFIG")
      echo "$TOKEN" | cachix authtoken --stdin
    else
      echo "No CACHIX_AUTH_TOKEN and no config at $CACHIX_CONFIG"
      exit 1
    fi

    cachix push "$CACHIX_NAME" "''${FILTERED_PATHS[@]}"
  '';
}
