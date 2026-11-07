{inputs, ...}: {
  # All overlays live in this one file on purpose: overlay order is semantic
  # (a later overlay sees the results of earlier ones), and spreading them over
  # feature files would leave that order at the mercy of import-tree.
  flake.modules.generic.base = {vars, ...}: {
    nixpkgs.overlays = [
      # Packages from ./packages that need `vars` (e.g. kubectl-debug's image name)
      (
        _final: prev:
          import ../../packages {
            pkgs = prev;
            inherit inputs vars;
          }
      )
      inputs.nixkit.overlays.default
      (
        _final: prev: let
          pkgs-copilot-cli = import inputs.nixpkgs-copilot-cli {
            inherit (prev.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          };
        in {
          # ⬇️ Leave here as example for building from source instead of nixpkg repo:
          # nh = inputs.nh.packages.${prev.stdenv.hostPlatform.system}.default;
          inherit
            (inputs.nixpkgs_fork.legacyPackages.${prev.stdenv.hostPlatform.system}.kubernetes-helmPlugins)
            helm-schema-dadav
            ;
          renovate = inputs.nixkit.packages.${prev.stdenv.hostPlatform.system}.renovate-jhc; # nixkit package built from github:JHOFER-Cloud/renovate
          inherit (inputs.claude-code.packages.${prev.stdenv.hostPlatform.system}) claude-code;
          # NOTE: MCP allowlist broken above 1.0.40
          inherit (pkgs-copilot-cli) github-copilot-cli;
          # Hashes from upstream fix NixOS/nixpkgs@c399e1b7. Only applies while the
          # pinned nixpkgs still has the old hash, so it goes inert once that lands.
          opencode =
            if prev.opencode.node_modules.outputHash == "sha256-xfOVcw1+waLVNhFDwzOtzxrUSQEogvn88YomydOlhwc="
            then
              prev.opencode.overrideAttrs (old: {
                node_modules = old.node_modules.overrideAttrs {
                  outputHash =
                    if prev.stdenv.hostPlatform.isLinux
                    then "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA="
                    else "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc=";
                };
              })
            else prev.opencode;
        }
      )
    ];
  };
}
