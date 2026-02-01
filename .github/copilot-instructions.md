# Copilot Instructions for dotfiles.nix

## Repository Overview

This is a **Nix Flakes-based configuration repository** for macOS (nix-darwin) and potentially Linux systems. It manages system configuration and dotfiles using declarative Nix expressions. The repository serves as the base configuration that can be consumed by other flake-based configurations (like nix-work).

**Key Technologies:**
- Nix Flakes (declarative package management and system configuration)
- nix-darwin (macOS system configuration)
- home-manager (user environment management)
- Just (command runner for builds and deployment)

**Size:** ~38 Nix modules across shared and macOS-specific configurations

## Build, Test, and Deployment

### Prerequisites
- Nix with flakes enabled
- Just command runner
- nh (Nix Helper) for deployment

### Commands (always run from repository root)

**Linting (always run before deployment):**
```bash
just lint
```
This runs `alejandra` formatter, `statix` checker, and `deadnix` for dead code detection.

**Format only:**
```bash
just format
```

**Deploy system configuration:**
```bash
just deploy
```
This will:
1. Run linting first
2. Pull latest changes from git
3. Stage all changes
4. Deploy using `nh darwin switch` (on macOS) or `nh os switch` (on Linux)

**Deploy with flake update:**
```bash
just deploy-update
```

**Full upgrade (update flake inputs and deploy):**
```bash
just upgrade
```

**Build without deploying:**
```bash
nix run nixpkgs#nh -- darwin build --no-nom -H mac .
```

**Clean nix store:**
```bash
just clean
```

**View available commands:**
```bash
just
```

### Build Time
- Linting: ~10-30 seconds
- Full build: 2-5 minutes (depending on cache hits)
- Deployment: 3-10 minutes

### Common Issues

1. **Rate limiting from GitHub:** The repository uses GITHUB_TOKEN from 1Password to prevent rate limiting. In CI, this is handled automatically.

2. **Unfree packages:** Some packages (like vesktop) require `nixpkgs.config.allowUnfree = true` in the configuration.

3. **Flake lock issues:** If you encounter flake.lock issues, the lint command will output the lock file for debugging.

## Project Structure

```
.
├── flake.nix                    # Main flake entry point, defines inputs and outputs
├── flake.lock                   # Locked dependency versions
├── justfile                     # Command runner recipes (build, deploy, lint, etc.)
├── .github/
│   └── workflows/
│       └── validate.yml         # CI workflow: security scan, lint, and build test
├── lib/                         # Custom Nix library functions
│   ├── default.nix             # Library entry point
│   ├── scanPaths.nix           # Recursive module discovery
│   └── helpers.nix             # makeOverlay, makePackages helpers
├── modules/                     # Reusable Nix modules
│   ├── shared/                 # Cross-platform modules
│   │   ├── system/             # System-level config (packages, core settings)
│   │   ├── home/               # Home Manager config (shell, editor, etc.)
│   │   ├── import-sys.nix      # System module importer
│   │   └── import-hm.nix       # Home Manager module importer
│   └── darwin/                 # macOS-specific modules
│       ├── system/             # macOS system settings
│       ├── home/               # macOS Home Manager modules
│       ├── import-sys.nix      # macOS system importer
│       └── import-hm.nix       # macOS home-manager importer
├── hosts/                       # Host-specific configurations
│   └── mac/                    # Configuration for "mac" host
│       ├── import-sys.nix      # Host system imports
│       └── import-hm.nix       # Host home-manager imports
├── packages/                    # Custom package definitions
│   ├── default.nix
│   ├── cachix-hook/
│   └── kubectl-debug/
├── vars/
│   └── personal.nix            # User variables (username, email, etc.)
├── scripts/
│   └── flake-rollback.fish     # Utility for rolling back flake inputs
├── .sops.yaml                   # Secrets management configuration
├── renovate.json               # Renovate dependency update config
└── README.md                   # Project documentation
```

## Architecture and Key Concepts

### Flake Structure

The flake exports:
1. **`sharedModules`**: Cross-platform system and home-manager modules
2. **`macModules`**: macOS-specific system and home-manager modules  
3. **`darwinConfigurations.mac`**: Complete macOS system configuration
4. **`lib`**: Helper functions for consuming flakes
5. **`packages`**: Custom package definitions for multiple platforms

### Module Loading Pattern

The repository uses a **recursive discovery pattern** via `scanPaths.nix`:
- Modules in `modules/*/system/` are automatically discovered and imported
- Home Manager modules in `modules/*/home/` are automatically discovered
- Host-specific configurations in `hosts/*/` override or extend base modules

### Overlays and Package Management

Custom packages and overrides are managed through overlays:
- Base packages overlay via `myLib.makeOverlay`
- nixkit overlay for extended Nix utilities
- Fork overlays for packages like `mist` from `nixpkgs_fork`
- Stable packages overlay for specific versions (e.g., vesktop from nixpkgs-stable)

### Key Dependencies

**Flake Inputs:**
- `nixpkgs`: Main package repository (unstable)
- `nixpkgs-stable`: Stable branch (release-25.05)
- `home-manager`: User environment management
- `darwin`: macOS system configuration
- `determinate`: Determinate Systems tools
- `nvf`: Neovim configuration framework
- `nixcord`: Discord customization
- `spicetify-nix`: Spotify customization
- `nixkit`: Custom Nix utilities

## CI/CD Pipeline

The `.github/workflows/validate.yml` workflow runs on push and pull requests:

1. **Security Check**: GitGuardian secret scanning
2. **Lint**: Runs `just lint` (statix + deadnix + alejandra)
3. **Build Test**: Builds configuration on macOS with `nh darwin build`

**Always ensure your changes pass linting before committing.** The CI will fail if lint does not pass.

## Guidelines for Changes

### When modifying Nix files:

1. **Always run `just lint` before committing.** This is required and enforced by CI.
2. **Test builds locally** with `just deploy` or the build-only command to catch issues early.
3. **Respect the module structure**: 
   - Shared modules go in `modules/shared/`
   - Platform-specific modules go in `modules/darwin/` or equivalent
   - Host-specific overrides go in `hosts/mac/`
4. **Use the recursive import pattern**: New modules are auto-discovered if placed in the correct directory structure.
5. **Follow Nix best practices**: Use `lib` functions, avoid impurities, prefer declarative configurations.

### When adding packages:

1. **Check for overlays**: New packages can be added to overlays in `flake.nix` or as separate package definitions in `packages/`.
2. **Unfree packages**: Remember to allow unfree in nixpkgs config if needed.
3. **Platform-specific packages**: Use `stdenv.hostPlatform.system` to conditionally include packages.

### When updating dependencies:

1. Use `just upgrade` to update flake inputs and deploy.
2. The `update-refs` command updates fetchers with newest commits and hashes.
3. Renovate is configured to automatically update dependencies.

### Variable Configuration:

User-specific variables (username, email, etc.) are defined in `vars/personal.nix` and passed as `specialArgs` to modules.

## Testing Your Changes

1. **Lint**: `just lint` (required, fast ~10-30s)
2. **Build**: `nix run nixpkgs#nh -- darwin build --no-nom -H mac .` (2-5 minutes)
3. **Deploy to test system**: `just deploy` (only on non-production systems)
4. **Review CI results**: Check that all workflow jobs pass

## Important Notes

- **Do not manually run `git commit` for deployments.** The `just upgrade` command handles commits automatically for dependency updates.
- **Always use `just` commands** rather than running `nix` or `nh` directly, as the justfile includes important flags and environment setup.
- **The justfile detects the OS** and runs appropriate commands (`darwin` on macOS, `os` on Linux).
- **CI runs on macOS only** (ubuntu-latest is commented out in the matrix).
- **Trust these instructions.** Only search if information is incomplete or found to be in error.
