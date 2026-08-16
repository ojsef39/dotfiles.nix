# dotfiles.nix

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://dotfiles.jhofer.de "Go to project documentation")
[![Build Status](https://github.com/ojsef39/dotfiles.nix/actions/workflows/validate.yml/badge.svg)](https://github.com/ojsef39/dotfiles.nix/actions/workflows/validate.yml)
![GitHub repo size](https://img.shields.io/github/repo-size/ojsef39/dotfiles.nix)
![GitHub License](https://img.shields.io/github/license/ojsef39/dotfiles.nix)

My central Nix configuration for macOS (and potentially Linux) systems. This
repository serves as the single source of truth for my system configuration and
dotfiles, managing everything from system settings to user applications.

> [!NOTE]
> Formerly `nix-base`. The `nix-personal` repository has been merged into this
> one.

<h1 align="center">
  <br><img src="https://nixcademy.com/_astro/nix-snowflake.DGxu8h81_1Dx4i6.svg" height="192px">
</h1>

## Layout

This flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic):
`flake.nix` declares inputs and nothing else, and every file under `modules/` is
a [flake-parts](https://flake.parts) module discovered automatically by
[import-tree](https://github.com/denful/import-tree).

Files are grouped by **feature**, not by platform or audience. A feature file
declares which configurations it applies to by writing into a named aggregate,
so a single `modules/git/default.nix` can hold both the shared git config and
the personal-only extras:

```nix
{
  flake.modules.homeManager.base = {vars, ...}: { programs.git = { /* ... */ }; };
  flake.modules.homeManager.personal = {vars, ...}: { /* never exported */ };
}
```

Paths containing `/_` are skipped by import-tree — that is how
`modules/editor/nvf/_parts/` stays out, since those files are `import`ed as
plain functions rather than being modules.

`modules/hosts/<name>/` holds one machine: the assembly plus anything true only
of that machine. It needs no edits when a feature is added. `modules/core/` holds the cross-cutting glue
(home-manager setup, overlays, the `vars` option).

## Module aggregates

| Aggregate | Scope | Exported |
| --- | --- | --- |
| `generic.base` | cross-platform system config | ✅ |
| `darwin.base` | nix-darwin system + home-manager wiring | ✅ |
| `nixos.base` | NixOS system + home-manager wiring | ✅ |
| `homeManager.base` | cross-platform home config | ✅ |
| `homeManager.darwin` / `homeManager.nixos` | platform-specific home config | ✅ |
| `generic.personal` / `homeManager.personal` | ojsef39's machines only | ❌ |
| `nixos.nvidia`, … | opt-in capability, imported by the hosts that want it | ❌ |
| `darwin.JosefsMacBookPro`, `nixos.josef-nd1-gpu0`, `homeManager.josef-nd1-gpu0` | one machine only | ❌ |

Configurations are named after the machine's hostname (which is pinned
declaratively in the host file), so `nh` resolves the right one without an
explicit `-H`. CI variants get a `-ci` suffix (`JosefsMacBookPro-ci`) and are
always named explicitly, since they never run on the machine itself.

Because a feature file declares its own audience, the files belonging to one
machine are spread across feature directories by design. To find them:

```console
$ just where josef-nd1-gpu0     # every file contributing to that aggregate
$ just aggregates               # every published aggregate name
```

Anything named after a machine lives in `modules/hosts/<name>/` — its assembly,
bootloader, filesystems, dock layout, host-only packages. A file named after one
host has no business in a feature directory, since by its own name it can never
be reused. Feature modules that a single machine merely *enables* stay with their
feature.

Hardware that another machine could plausibly also have is an **opt-in
capability** instead: its own aggregate under `modules/hardware/`, which a host
imports explicitly. Variants within one capability are options rather than
separate modules, so the host reads as an inventory of what the machine is:

```nix
# modules/hosts/josef-nd1-gpu0/default.nix
modules = [
  m.nixos.base
  m.generic.personal

  # Optional capabilities this machine has
  m.nixos.nvidia
  {gpuType.rtx4080 = true;}

  m.nixos.josef-nd1-gpu0
];
```

`darwin.base` and `nixos.base` each import `generic.base` and the matching
`homeManager.*` aggregates, so a consumer imports exactly one module. Anything
not reachable from a `*.base` aggregate can never reach a downstream config —
that is the "don't pollute work machines" boundary, and it is greppable rather
than dependent on directory layout.

## Using this as a base for another config

Add this flake as an input, point `nixpkgs` at it so you don't end up with two
nixpkgs in one closure, then import the aggregate and supply `vars`:

```nix
{
  inputs = {
    base.url = "github:ojsef39/dotfiles.nix";
    nixpkgs.follows = "base/nixpkgs";
    darwin.follows = "base/darwin";
  };

  outputs = {base, darwin, ...}: {
    darwinConfigurations.work = darwin.lib.darwinSystem {
      modules = [
        base.modules.darwin.base
        {nixpkgs.hostPlatform = "aarch64-darwin";}
        {
          vars = {
            user = {
              name = "jhofer";
              full_name = "Josef Hofer";
              email = "josef.hofer@example.com";
            };
            git = {
              ghq = "workspace";
              dotfiles = "git.example.com/jhofer/nix-work";
              url = "git.example.com";
            };
          };
        }
        ./modules # your own modules, or your own import-tree
      ];
    };
  };
}
```

That is the whole contract. No `specialArgs`: `inputs`, `baseLib` and `vars` are
supplied by the imported modules themselves.

`vars` is a typed option — see `modules/core/vars.nix` for the full set. Only
`user.name`, `user.full_name`, `user.email` and `git.dotfiles` are required;
everything else has a default, and a missing key gives a named option error
rather than a stray `attribute ... missing`. The type is freeform, so you can
keep your own private keys in the same attrset.

To drop something from the base, use the module system rather than forking —
base modules are written `enable`-style:

```nix
{lib, ...}: {
  home-manager.users.jhofer.programs.k9s.enable = lib.mkForce false;
}
```

`base.lib` additionally exposes `mkHome`, `mkDotPath` and `mkOpAgentSock`.
