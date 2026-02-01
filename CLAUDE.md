# Copilot Instructions for dotfiles.nix

## What You Are Working With

A **Nix Flakes-based dotfiles repository** (~38 modules) for macOS/Linux system configuration using nix-darwin and home-manager. This is a base configuration consumed by other flakes (like nix-work).

**Stack:** Nix Flakes, nix-darwin, home-manager, Just (command runner)

## Your Role and Boundaries

**You should:**
- Assist with code changes to Nix modules, packages, and configurations
- Validate changes by linting and building (never deploying)
- Navigate the codebase efficiently using the structure below
- Follow Nix best practices and existing patterns

**You should NOT:**
- Deploy or apply system configurations (`just deploy`, `just upgrade`, etc.)
- Modify the user's live system
- Run commands that require 1Password authentication
- Update flake inputs unless explicitly asked

## Validating Your Changes

**Always run these commands to validate changes:**

1. **Lint (REQUIRED before committing):**
   ```bash
   just lint
   ```
   Runs: alejandra (formatter), statix (checker), deadnix (unused code detection)
   Time: ~10-30 seconds

2. **Build (test that config evaluates correctly):**
   ```bash
   nix run nixpkgs#nh -- darwin build --no-nom -H mac .
   ```
   Time: 2-5 minutes (depending on cache)

**Note:** The CI pipeline will run these same checks. Lint failures will block the PR.

## Common Pitfalls

- **Unfree packages** (e.g., vesktop) need `nixpkgs.config.allowUnfree = true`
- **GitHub rate limiting** happens in CI but is handled automatically with tokens
- **Flake.lock issues** are debugged by the lint command which outputs the lock file

## How to Navigate This Codebase

**Key entry points:**
- `flake.nix` - Exports `sharedModules`, `macModules`, `darwinConfigurations.mac`, `lib`, `packages`
- `flake.lock` - Locked dependency versions (don't manually edit)
- `justfile` - Available commands (use for validation only)

**Module organization (auto-discovered via `lib/scanPaths.nix`):**
```
modules/
├── shared/              # Cross-platform (Linux + macOS)
│   ├── system/          # System-level: packages, core config
│   └── home/            # Home Manager: shell, editor, CLI tools
└── darwin/              # macOS-specific
    ├── system/          # macOS system settings
    └── home/            # macOS Home Manager modules
```

**Module discovery pattern:** Files in `modules/*/system/` and `modules/*/home/` are **automatically imported** via the import-*.nix files. Just place a new .nix file in the right directory.

**Host-specific config:**
- `hosts/mac/` - Overrides/extends base modules for the "mac" host
- Host configs also use auto-discovery pattern

**Custom code:**
- `lib/` - Helper functions (makeOverlay, makePackages, scanPaths)
- `packages/` - Custom package definitions (cachix-hook, kubectl-debug)
- `vars/personal.nix` - User variables passed as `specialArgs`

## Architecture Patterns You Need to Know

### Flake Output Structure
The flake exports modules for consumption by other configurations:
- `sharedModules` - Base system + home-manager modules (cross-platform)
- `macModules` - macOS-specific additions
- `darwinConfigurations.mac` - Complete macOS config (combines both)
- `lib` - Helper functions for downstream flakes
- `packages` - Custom packages for aarch64-darwin, x86_64-darwin, x86_64-linux

### Overlays (for package customization)
Multiple overlays are layered in `flake.nix`:
1. Base packages via `myLib.makeOverlay` (defined in lib/helpers.nix)
2. nixkit overlay (extended Nix utilities)
3. Fork overlay (custom packages like `mist` from nixpkgs_fork)
4. Stable overlay (specific versions from nixpkgs-stable, e.g., vesktop)

### Key Flake Inputs
- `nixpkgs` - Main package repository (unstable branch)
- `nixpkgs-stable` - Stable branch for specific packages (release-25.05)
- `nixpkgs_fork` - Personal fork with custom packages
- `home-manager` - User environment management
- `darwin` - macOS system configuration framework
- `nvf` - Neovim configuration
- `nixcord`, `spicetify-nix` - App customizations
- `nixkit` - Extended Nix utilities

## Making Changes: Patterns to Follow

### Adding a New Module
1. Create `modules/shared/system/my-module.nix` or `modules/shared/home/my-module.nix`
2. It's automatically discovered - no manual import needed
3. Lint and build to verify

### Adding a Package
- **Via overlay:** Add to an overlay in `flake.nix`
- **Custom package:** Create in `packages/my-package/default.nix`
- **Unfree package:** Ensure `nixpkgs.config.allowUnfree = true` is set

### Module Structure Best Practices
- Use `lib` functions (mkIf, mkOption, etc.)
- Keep configurations declarative (no impure operations)
- Platform-specific code goes in `modules/darwin/`, not `modules/shared/`
- Use `vars.user.name` and other variables from `specialArgs`

## CI Pipeline (What Will Check Your Changes)

The `.github/workflows/validate.yml` runs three checks:
1. **GitGuardian** - Secret scanning
2. **Lint** - `just lint` (statix, deadnix, alejandra)
3. **Build** - `nh darwin build` on macOS runner

Your changes must pass lint and build to merge.
