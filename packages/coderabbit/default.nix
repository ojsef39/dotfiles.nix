# coderabbit keeps one global active org in ~/.coderabbit/auth.json.
# This wrapper switches it to the git remote owner before every call
# (except `auth ...`) and says so on stderr.
# TESTING — smoke-test these on every change:
#   cd <JHOFER-Cloud repo> && coderabbit --version   # prints "switched org ojsef39 → JHOFER-Cloud"
#   coderabbit auth status                           # Organization : JHOFER-Cloud
#   cd <ojsef39 repo> && coderabbit --version        # switches back
{
  lib,
  writeShellApplication,
  coderabbit-cli,
  git,
  jq,
}:
writeShellApplication {
  name = "coderabbit";
  runtimeInputs = [git jq];
  text = ''
    auth="$HOME/.coderabbit/auth.json"
    remote=$(git remote get-url origin 2>/dev/null || true)

    if [[ "''${1:-}" != auth && -f "$auth" && -n "$remote" ]]; then
      # git@host:owner/repo.git, https://host/owner/repo, ssh://git@host/owner/repo
      owner=$(sed -E 's#^.*[:/]([^/:]+)/[^/]+/?$#\1#' <<<"$remote")
      owner=''${owner,,}
      current=$(jq -r '.currentOrg.name' "$auth")

      if [[ -n "$owner" && "$owner" != "''${current,,}" ]]; then
        tmp=$(mktemp "$auth.XXXXXX")
        if jq -e --arg o "$owner" '
          (.organizations[] | select(.name | ascii_downcase == $o)) as $org
          | .currentOrg = $org | .workspaceId = $org.workspace_id' "$auth" >"$tmp"; then
          mv "$tmp" "$auth"
          printf '\033[33mcoderabbit: switched org %s → %s\033[0m\n' \
            "$current" "$(jq -r '.currentOrg.name' "$auth")" >&2
        else
          rm -f "$tmp"
        fi
      fi
    fi

    exec ${lib.getExe coderabbit-cli} "$@"
  '';
}
