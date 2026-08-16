# Repository Structure

This flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic).
`flake.nix` declares inputs and nothing else; every file under `modules/` is a
[flake-parts](https://flake.parts) module discovered automatically by
[import-tree](https://github.com/denful/import-tree).

```graphql
.
├── flake.nix               # Inputs, then: mkFlake (import-tree ./modules)
├── vars/                   # Per-configuration identity (see modules/core/vars.nix)
├── packages/               # Own package definitions
└── modules/                # Every file here is a flake-parts module
    ├── flake/              # Flake-level plumbing: systems, lib, packages, devshell
    ├── core/               # Cross-cutting glue
    │   ├── aggregates.nix    # Placeholders for aggregates that may be empty
    │   ├── args.nix          # Supplies `inputs` / `baseLib` to exported modules
    │   ├── vars.nix          # Declares the `vars` option and its defaults
    │   ├── nixpkgs.nix       # All overlays, in one place so order is stable
    │   ├── home.nix          # home-manager basics for every user
    │   ├── darwin.nix        # darwin.base: nix-darwin + home-manager setup
    │   └── nixos.nix         # nixos.base: NixOS + home-manager setup
    ├── hosts/              # One directory per machine
    │   ├── JosefsMacBookPro/
    │   │   ├── default.nix   # The darwinSystem call
    │   │   ├── dock.nix      # This machine's dock layout
    │   │   ├── homebrew.nix
    │   │   └── packages.nix
    │   └── josef-nd1-gpu0/
    │       ├── default.nix   # The nixosSystem call
    │       ├── host.nix      # Bootloader, filesystems
    │       ├── hardware.nix  # hardware-configuration
    │       └── packages.nix
    ├── hardware/           # Opt-in capabilities a host imports, e.g. nvidia.nix
    ├── k9s.nix             # A feature small enough to be one file
    └── git/                # A feature with several files or assets
        ├── default.nix
        ├── ghq.nix
        └── personal.nix
```

Features are grouped by **feature**, not by platform or audience. A feature is a
single `<name>.nix` file, or a `<name>/` directory once it needs more than one
file (extra modules, or assets such as `kitty/scripts/`).

A file says which configurations it applies to by writing into a named aggregate,
and one file can write to several. Audiences do not need a file each:

```nix
# modules/git/default.nix
{
  flake.modules.homeManager.base = {vars, ...}: { programs.git = { /* ... */ }; };

  # mixing audiences in one file is fine, and preferred while it stays small
  flake.modules.homeManager.personal = {vars, ...}: { /* never exported */ };
}
```

Splitting a section into its own file is purely a size decision. It changes
nothing about how the modules merge:

```nix
# modules/git/personal.nix
{
  flake.modules.homeManager.personal = {vars, ...}: { /* never exported */ };
}
```

Paths containing `/_` are skipped by import-tree. That is how
`modules/editor/nvf/_parts/` stays out, since those files are `import`ed as plain
functions rather than being modules.

## Finding things

Because audience is declared in the file rather than encoded in the path, the
files belonging to one machine are spread across feature directories. To locate
them:

```console
$ just where josef-nd1-gpu0     # every file contributing to that aggregate
$ just aggregates               # every published aggregate name
```

See the [README](https://github.com/ojsef39/dotfiles.nix#module-aggregates) for
the full aggregate table and how to consume this flake as a base for another
configuration.
