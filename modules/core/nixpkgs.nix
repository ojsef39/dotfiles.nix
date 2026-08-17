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
            inherit vars;
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
          renovate = prev.renovate-jhc; # nixkit package built from github:JHOFER-Cloud/renovate
          inherit (inputs.claude-code.packages.${prev.stdenv.hostPlatform.system}) claude-code;
          # NOTE: MCP allowlist broken above 1.0.40
          inherit (pkgs-copilot-cli) github-copilot-cli;
          moonlight-qt = prev.moonlight-qt.overrideAttrs (old: {
            qmakeFlags = (old.qmakeFlags or []) ++ ["QMAKE_LFLAGS+=-fuse-ld=lld"];
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.lld];
          });
        }
      )
    ];
  };
}
