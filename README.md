# dotfiles.nix

[![Build Status](https://github.com/ojsef39/dotfiles.nix/actions/workflows/validate.yml/badge.svg)](https://github.com/ojsef39/dotfiles.nix/actions/workflows/validate.yml)
![GitHub repo size](https://img.shields.io/github/repo-size/ojsef39/dotfiles.nix)
![GitHub License](https://img.shields.io/github/license/ojsef39/dotfiles.nix)

My central Nix configuration for macOS (and potentially Linux) systems. This
repository serves as the single source of truth for my system configuration and
dotfiles, managing everything from system settings to user applications.

> [!NOTE]
> Formerly `nix-base`. The `nix-personal` repository has been merged into this
> one.

## Features

- **Flake-based**: Uses Nix Flakes for reproducible and hermetic dependency
  management.

## Repository Structure

```graphql
.
├── flake.nix             # Entry point, input definitions, and output composition
├── lib/                  # Custom Nix library functions
│   ├── default.nix       # Library entry point
│   ├── scanPaths.nix     # Recursive module discovery logic
│   └── helpers.nix       # Flake helpers (makeOverlay, makePackages)
├── modules/              # Reusable modules
│   ├── shared/           # Cross-platform modules
│   │   ├── system/       # System-level config (e.g., core, packages)
│   │   └── home/         # Home Manager config (e.g., shell, editor)
│   └── darwin/           # macOS-specific modules
│       ├── system/       # macOS system settings
│       └── home/         # macOS Home Manager modules
└── hosts/                # Host-specific configurations
    └── mac/              # Configuration for "mac" host
        ├── import-sys.nix # Recursive system import
        └── import-hm.nix  # Recursive home-manager import
```

## External Usage

This flake exposes its modules for consumption by other configurations (like
`nix-work`), allowing for a layered configuration approach where `dotfiles.nix`
provides the base.

Remote building with 1Password as SSH Agent:

```bash
nix build .#darwinConfigurations.mac.system --builders 'ssh://<user>@<ip> x86_64-linux,aarch64-darwin'
```

> Make sure you ran `sudo ssh <user>@<ip>` first and accept the host key dialog,
> otherwise remote build will fail as that runs as root (nix daemon).

### Exported Modules

- **`sharedModules`**: Core system configuration, packages, and shared Home
  Manager modules.
- **`macModules`**: macOS-specific system modules and settings.

### Output Structure

The flake outputs are structured to be easily consumed:

```nix
outputs = { ... }: {
  sharedModules = [ ... ]; # Base modules
  macModules = [ ... ];    # macOS modules
  lib = { ... };           # Helper library
};
```

### Example: `nix-work` Consumption

To build a work configuration on top of this base:

```nix
{
  inputs.base.url = "github:ojsef39/dotfiles.nix";

  outputs = { base, ... }: {
    darwinConfigurations.workMac = darwin.lib.darwinSystem {
      modules =
        base.outputs.sharedModules
        ++ base.outputs.macModules
        ++ [
          ./work-specific-config.nix
        ];
      specialArgs = {
        baseLib = base.lib;
      };
    };
  };
}
```

## Setup & Deployment

This configuration is managed using `nh` (Nix Helper) and `just`.
