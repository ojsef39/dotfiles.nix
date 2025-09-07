# nix-base

[![Build Status](https://github.com/ojsef39/nix-base/actions/workflows/validate.yml/badge.svg)](https://github.com/ojsef39/nix-base/actions/workflows/validate.yml)
![GitHub repo size](https://img.shields.io/github/repo-size/ojsef39/nix-base)
![GitHub License](https://img.shields.io/github/license/ojsef39/nix-base)

This repository contains my public Nix base configuration for both macOS and Linux systems.

It is designed to be used as an input in another nix config, see an example: [ojsef39/nix-personal](https://github.com/ojsef39/nix-personal)

## Structure

```

```

## TODOs

- [ ] Move pkgs for all systems to shared/pkgs.nix
  - [ ] Move packages to where they get used e.g. eza to shell/default.nix
- [ ] Use Vesktop instead of Discord
- [ ] Update READMEs

## Key Files and Their Purpose

### Top-Level Files

- `flake.nix`: Entry point for the Nix flake configuration, defining inputs and outputs.
- `Makefile`: Automation scripts for building and deploying configurations.
- `renovate.json`: Configuration for dependency updates.

### Shared Configuration

- `nix/core.nix`: Core Nix configurations shared across all systems.

- `hosts/shared/`: Shared configurations and programs used by both macOS and Linux.
  - `import.nix`: Imports shared program modules.
  - `programs/`: Contains configurations for various programs:
    - `editor/`
    - `git/`
    - `kitty/`
    - `shell/`
    - `ssh/`
    - `yuki/`
    - `…`

### macOS Configuration (`nix-darwin`)

- `hosts/darwin/`:
  - `import.nix`: Imports macOS-specific modules.
  - `system.nix`: System-level settings and preferences for macOS.
  - `homebrew.nix`: Homebrew package configurations (gets imported seperately).
  - `apps.nix`: Additional applications to install on macOS.

## Useful commands for upstream nix configuration

Check if vars are correctly set:
`nix eval .#darwinConfigurations.mac._module.specialArgs.vars.cachix.ignorePatterns`

Check if Brew list got merged correctly:

`nix eval .#darwinConfigurations.mac.config.homebrew.masApps`

Check if programs got merged correctly:

`nix eval .#darwinConfigurations.mac.config.system.programs.zsh.sessionVariables.PATH`
