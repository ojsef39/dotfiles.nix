# Repository Structure

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
