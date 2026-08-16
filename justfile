#!/usr/bin/env just --justfile

alias d := deploy
alias u := upgrade

# macOS need nh darwin switch and NixOS needs nh os switch
nix_cmd := `if [ "$(uname)" = "Darwin" ]; then echo "darwin"; else echo "os"; fi`
# Configurations are named after the machine, so this needs no per-OS special
# case. -s because macOS `hostname` returns the FQDN (JosefsMacBookPro.local).
nix_host := `hostname -s`
# Use GITHUB_TOKEN from 1Password to prevent rate limiting (only if op is available and connected)
nix_flags := ```
  if [ "${GITHUB_ACTIONS:-}" != "true" ] && command -v op > /dev/null 2>&1; then
    token=$(op read op://Personal/GITHUB_TOKEN/no_access 2>/dev/null)
    if [ -n "$token" ]; then
      echo "--option access-tokens github.com=$token"
    fi
  fi
  ```

[doc('HELP')]
default:
    @just --list --list-prefix "    " --list-heading $'🔧 Available Commands:\n'

[group('nix')]
[doc('Deploy system configuration')]
deploy: lint
    # Deploying system configuration without update...
    @git pull --rebase --autostash || true
    @git add .
    @nh {{nix_cmd}} switch -a -H {{nix_host}} $NIX_GIT_PATH -- {{nix_flags}}

[group('nix')]
[doc('Deploy system configuration')]
deploy-update: lint
    # Deploying system configuration with update...
    @git pull --rebase --autostash || true
    @git add .
    @nh {{nix_cmd}} switch -u -a -H {{nix_host}} $NIX_GIT_PATH -- {{nix_flags}}

[group('nix')]
[doc('Upgrade refs and deploy')]
upgrade: update-refs lint
    @git pull --rebase --autostash || true
    @git add .
    @nh {{nix_cmd}} switch -a -H {{nix_host}} $NIX_GIT_PATH -- {{nix_flags}}
    @git add .
    @if git log -1 --pretty=%B | grep -q "chore(deps): updated inputs and refs"; then \
        echo "Amending previous dependency update commit..."; \
        git commit --amend --no-edit || true; \
    else \
        git commit -m "chore(deps): updated inputs and/or refs" || true; \
    fi


[group('nix')]
[doc('Update every fetcher with its newest commit and hash')]
update-refs:
    # Update current repository
    @kitten @ launch --type=overlay --title="update-nix-fetchgit-all" --copy-env --env SKIP_FF=1 fish -c "cd $NIX_GIT_PATH && update-nix-fetchgit-all"

[group('nix')]
[doc('List module files that define or import an aggregate, e.g. `just where nvidia`')]
where aggregate:
    #!/usr/bin/env bash
    # Matches `flake.modules.<class>.<name>` (a definition) and `m.<class>.<name>`
    # (a host importing it) — not bare occurrences of the word.
    def=$(grep -rlE "flake\.modules\.[a-zA-Z]+\.{{aggregate}}\b" --include='*.nix' modules || true)
    use=$(grep -rlE "\bm\.[a-zA-Z]+\.{{aggregate}}\b"            --include='*.nix' modules || true)
    if [ -z "$def$use" ]; then echo "nothing defines or imports '{{aggregate}}'"; exit 0; fi
    if [ -n "$def" ]; then echo "defined by:";  echo "$def" | sed 's/^/  /'; fi
    if [ -n "$use" ]; then echo "imported by:"; echo "$use" | sed 's/^/  /'; fi

[group('nix')]
[doc('List all published module aggregates')]
aggregates:
    @nix eval --json .#modules --apply 'm: builtins.mapAttrs (_: builtins.attrNames) m' | nix run nixpkgs#jq -- .

[group('maintain')]
[doc('Clean and optimise the nix store with nh')]
clean:
    @nh clean all -a -k 2 -K 7d

[group('maintain')]
[doc('Optimise the nix store')]
optimise:
    @nix store optimise -v

[group('maintain')]
[doc('Verify and repair the nix-store')]
repair:
    @sudo nix-store --verify --check-contents --repair || true

[group('maintain')]
[doc('Selectively rollback flake inputs')]
rollback:
    @./scripts/flake-rollback.fish

[group('lint')]
[doc('Lint all nix files using statix and deadnix')]
lint: format
    @nix run {{nix_flags}} nixpkgs#statix -- check .
    @nix run {{nix_flags}} nixpkgs#deadnix -- -eq .

[group('lint')]
[doc('Format files using alejandra')]
format:
    @nix run {{nix_flags}} nixpkgs#alejandra -- .

[group('lint')]
[doc('Show diff between current and commited changes')]
diff:
    git diff ':!flake.lock'
