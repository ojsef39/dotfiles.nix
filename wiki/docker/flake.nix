{
  description = "Nix Docker image examples";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/JHOFER-Cloud/NixOS-nixpkgs/0.1.tar.gz"; # usually github:NixOS/nixpkgs/nixpkgs-unstable
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Get Linux packages - works on macOS with Determinate's built-in linux-builder
      # This uses the linux-builder to build natively for Linux (fast, fully cached)
      linuxPkgs = import pkgs.path {system = "x86_64-linux";};

      # Alternative: Cross-compile to Linux (no cache, slower first build)
      # linuxPkgs = pkgs.pkgsCross.musl64;

      # Example 1: buildLayeredImage - pure Nix, from scratch
      layeredImage = pkgs.dockerTools.buildLayeredImage {
        name = "nix-shell";
        tag = "latest";
        contents = [linuxPkgs.busybox];
        config.Cmd = ["/bin/sh"];
      };

      # Example 2: buildImage with Ubuntu base
      ubuntuBase = pkgs.dockerTools.pullImage {
        imageName = "ubuntu";
        imageDigest = "sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b";
        sha256 = "sha256-9vmJV6M21tZPk39lCCdCrwHR55gNzO1ka2De51IR9qs=";
        finalImageTag = "24.04";
      };

      ubuntuImage = pkgs.dockerTools.buildImage {
        name = "ubuntu-nix";
        tag = "latest";
        fromImage = ubuntuBase;
        copyToRoot = pkgs.buildEnv {
          name = "nix-tools";
          paths = [linuxPkgs.busybox];
        };
        config.Cmd = ["/bin/sh"];
      };
    in {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          echo "Loading Docker images..."

          if command -v podman &>/dev/null; then
            podman load < ${layeredImage}
            podman load < ${ubuntuImage}
          elif command -v docker &>/dev/null; then
            docker load < ${layeredImage}
            docker load < ${ubuntuImage}
          else
            echo "No container runtime found"
            exit 1
          fi

          echo "Images loaded: ${layeredImage.imageName}:${layeredImage.imageTag}, ${ubuntuImage.imageName}:${ubuntuImage.imageTag}"
        '';
      };
    });
}
