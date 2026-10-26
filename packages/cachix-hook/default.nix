{
  pkgs,
  cachixName ? "ojsef39",
  ignorePatterns ? [],
  vars,
}:
pkgs.writeShellApplication {
  name = "cachix-push-hook";
  runtimeInputs = [
    pkgs.cachix
    pkgs.gawk
  ];
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

    USER_HOME=$(eval echo "~${vars.user.name}")
    CACHIX_CONFIG="$USER_HOME/.config/cachix/cachix.dhall"
    if [[ -f "$CACHIX_CONFIG" ]]; then
      CACHIX_AUTH_TOKEN=$(awk '/authToken/{getline; gsub(/[" ]/, ""); print}' "$CACHIX_CONFIG")
      export CACHIX_AUTH_TOKEN
    else
      echo "No CACHIX_AUTH_TOKEN and no config at $CACHIX_CONFIG"
      exit 1
    fi

    # Retry transient failures; persistent ones (e.g. expired token) still fail the build
    for attempt in 1 2 3; do
      cachix push "$CACHIX_NAME" "''${FILTERED_PATHS[@]}" && exit 0
      echo "cachix push failed (attempt $attempt/3)" >&2
      sleep $((attempt * 5))
    done
    exit 1
  '';
}
