# Repository Structure

This flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic).
`flake.nix` declares inputs and nothing else; every file under `modules/` is a
[flake-parts](https://flake.parts) module discovered automatically by
[import-tree](https://github.com/denful/import-tree).

```graphql
.
├── flake.nix             # Inputs, then: mkFlake (import-tree ./modules)
├── vars/                 # Per-configuration identity (see modules/wiring/vars.nix)
├── packages/             # Own package definitions
└── modules/              # Every file here is a flake-parts module
    ├── flake/            # Flake-level plumbing: systems, lib, packages, devshell
    ├── wiring/           # Cross-cutting glue
    │   ├── aggregates.nix  # Declares every published aggregate
    │   ├── args.nix        # Supplies `inputs` / `baseLib` to exported modules
    │   ├── vars.nix        # Declares the `vars` option and its defaults
    │   ├── nixpkgs.nix     # All overlays, in one place so order is stable
    │   ├── darwin.nix      # darwin.base: nix-darwin + home-manager wiring
    │   └── nixos.nix       # nixos.base: NixOS + home-manager wiring
    ├── hosts/            # One machine per entry; assembly + host identity only
    │   ├── JosefsMacBookPro.nix
    │   └── josef-nd1-gpu0/
    │       ├── default.nix   # The nixosSystem call
    │       ├── host.nix      # Bootloader, filesystems
    │       ├── hardware.nix  # hardware-configuration
    │       └── nvidia.nix
    └── <feature>/        # git, shell, editor, k9s, hyprland, steam, ...
```

Feature directories are grouped by **feature**, not by platform or audience. A
file declares which configurations it applies to by writing into a named
aggregate, so one directory can serve several audiences at once:

```nix
# modules/git/default.nix
{
  flake.modules.homeManager.base = {vars, ...}: { programs.git = { /* ... */ }; };
}

# modules/git/personal.nix
{
  flake.modules.homeManager.personal = {vars, ...}: { /* never exported */ };
}
```

Paths containing `/_` are skipped by import-tree. That is how
`modules/editor/nvf/_parts/` stays out — those files are `import`ed as plain
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
