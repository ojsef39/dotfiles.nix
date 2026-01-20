#!/usr/bin/env just --justfile

alias d := deploy
alias u := upgrade

# macOS need nh darwin switch and NixOS needs nh os switch
nix_cmd := `if [ "$(uname)" = "Darwin" ]; then echo "darwin"; else echo "os"; fi`
nix_host := `if [ "$(uname)" = "Darwin" ]; then echo "mac"; else echo "nixos"; fi`
# Use GITHUB_TOKEN from 1Password to prevent rate limiting
NIX_CONFIG := `if [ "${GITHUB_ACTIONS:-}" != "true" ]; then echo "access-tokens = github.com=$(op read op://Personal/GITHUB_TOKEN/no_access)"; fi`

[doc('HELP')]
default:
    @just --list --list-prefix "    " --list-heading $'🔧 Available Commands:\n'

[group('nix')]
[doc('Deploy system configuration')]
deploy: lint
    # Deploying system configuration without update...
    @git pull || true
    @git add .
    @NIX_CONFIG="{{NIX_CONFIG}}" nh {{nix_cmd}} switch -a -H {{nix_host}} $NIX_GIT_PATH

[group('nix')]
[doc('Deploy system configuration')]
deploy-update: lint
    # Deploying system configuration with update...
    @git pull || true
    @git add .
    @NIX_CONFIG="{{NIX_CONFIG}}" nh {{nix_cmd}} switch -u -a -H {{nix_host}} $NIX_GIT_PATH

[group('nix')]
[doc('Upgrade flake inputs and deploy')]
upgrade: update-refs lint
    @git pull || true
    @git add .
    @NIX_CONFIG="{{NIX_CONFIG}}" nh {{nix_cmd}} switch -u -a -H {{nix_host}} $NIX_GIT_PATH
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
    @kitten @ launch --type=overlay --title="update-nix-fetchgit-all" --copy-env --env SKIP_FF=1 fish -C "cd $NIX_GIT_PATH && update-nix-fetchgit-all && exit 0"

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
    @NIX_CONFIG="{{NIX_CONFIG}}" nix run nixpkgs#statix -- check .
    @NIX_CONFIG="{{NIX_CONFIG}}" nix run nixpkgs#deadnix -- -eq .

[group('lint')]
[doc('Format files using alejandra')]
format:
    @NIX_CONFIG="{{NIX_CONFIG}}" nix run nixpkgs#alejandra -- .

[group('lint')]
[doc('Show diff between current and commited changes')]
diff:
    git diff ':!flake.lock'
