# Docker - Building container images with Nix

Example flake showing `buildLayeredImage` and `buildImage` with Ubuntu base.

## Try it out

```bash
cd wiki/docker && nix develop -c $SHELL
```

or with [nix-output-monitor](https://github.com/maralorn/nix-output-monitor)
(`nom develop -c $SHELL`) for a nice overview of build progress

This will build and load two Docker images:

- `nix-shell:latest` - Pure Nix image using buildLayeredImage
- `ubuntu-nix:latest` - Ubuntu base with Nix tools using buildImage

## flake.nix

```nix
{{#include ../../docker/flake.nix}}
```

## How it works

### Linux Builder (Recommended)

The flake uses Determinate's built-in Linux builder on macOS:

```nix
linuxPkgs = import pkgs.path {system = "x86_64-linux";};
```

This builds natively for Linux using the remote builder, which is fast and fully
cached.

### Cross-compilation Alternative

Alternatively, you can cross-compile using:

```nix
linuxPkgs = pkgs.pkgsCross.musl64;
```

Note: This approach has no binary cache, so first builds will be slower.

## Resources

- [dockerTools documentation](https://ryantm.github.io/nixpkgs/builders/images/dockertools/)
- [Installing Nix with Docker support](https://manual.determinate.systems/installation/installing-docker.html)
