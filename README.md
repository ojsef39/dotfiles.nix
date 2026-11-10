<p align="center">
    <a href="http://www.hexley.com/license.html">
    <img src="https://github.com/user-attachments/assets/3db65c06-1c36-4ddd-bcb9-66beaae39d5d" width=225/>
    </a>
    <h1 align="center"><code>dotfiles.nix</code></h1>
    <div align="center">
    <a href="https://dotfiles.jhofer.de" title="Go to project documentation"><img src="https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge" height=20/></a>
    <img src="https://github.com/ojsef39/dotfiles.nix/actions/workflows/validate.yml/badge.svg" height=20/>
    <img src="https://img.shields.io/github/repo-size/ojsef39/dotfiles.nix" height=20/>
    <img src="https://img.shields.io/github/license/ojsef39/dotfiles.nix" height=20/>
    </div>
</p>

My central Nix configuration for macOS and Linux systems. This
repository serves as the single source of truth for my system configuration and
dotfiles, managing everything from system settings to user applications.

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

Paths containing `/_` are skipped by import-tree. That is how
`modules/editor/nvf/_parts/` stays out, since those files are `import`ed as
plain functions rather than being modules.

`modules/hosts/<name>/` holds one machine: the assembly plus anything true only
of that machine. It needs no edits when a feature is added. `modules/core/` holds the cross-cutting glue
(home-manager setup, overlays, the `vars` option).

## Module aggregates

| Aggregate                                                                       | Scope                                                 | Exported |
| ------------------------------------------------------------------------------- | ----------------------------------------------------- | -------- |
| `generic.base`                                                                  | cross-platform system config                          | ✅       |
| `darwin.base`                                                                   | nix-darwin system + home-manager wiring               | ✅       |
| `nixos.base`                                                                    | NixOS system + home-manager wiring                    | ✅       |
| `homeManager.base`                                                              | cross-platform home config                            | ✅       |
| `homeManager.darwin` / `homeManager.nixos`                                      | platform-specific home config                         | ✅       |
| `generic.personal` / `darwin.personal` / `homeManager.personal`                 | ojsef39's machines only                               | ❌       |
| `nixos.nvidia`, …                                                               | opt-in capability, imported by the hosts that want it | ❌       |
| `darwin.JosefsMacBookPro`, `nixos.josef-nd1-gpu0`, `homeManager.josef-nd1-gpu0` | one machine only                                      | ❌       |

Configurations are named after the machine's hostname (which is pinned
declaratively in the host file), so `nh` resolves the right one without an
explicit `-H`. CI variants get a `-ci` suffix (`JosefsMacBookPro-ci`) and are
always named explicitly, since they never run on the machine itself.

Because a feature file declares its own audience, the files belonging to one
machine are spread across feature directories by design. To find them:

```console
just where josef-nd1-gpu0     # every file contributing to that aggregate
just aggregates               # every published aggregate name
```

Anything named after a machine lives in `modules/hosts/<name>/`: its assembly,
bootloader, filesystems, dock layout, host-only packages. A file named after one
host has no business in a feature directory, since by its own name it can never
be reused. Feature modules that a single machine merely _enables_ stay with their
feature.

Anything another machine could plausibly also have is an **opt-in capability**
instead: it writes to its own aggregate name, which a host imports explicitly.
Variants within one capability are options rather than separate modules, so the
host reads as an inventory of what the machine is:

```nix
# modules/hosts/josef-nd1-gpu0/default.nix
modules = [
  m.nixos.base
  m.generic.personal

  # Optional capabilities this machine has
  m.nixos.nvidia
  {gpuType.rtx5080 = true;}

  m.nixos.josef-nd1-gpu0
];
```

`darwin.base` and `nixos.base` each import `generic.base` and the matching
`homeManager.*` aggregates, so a consumer imports exactly one module. Anything
not reachable from a `*.base` aggregate can never reach a downstream config.
That is the "don't pollute work machines" boundary, and it is greppable rather
than dependent on directory layout.

### Why folders never encode audience

The aggregate name is the _only_ place that records who a module is for, and
whether it applies automatically or has to be opted into. Directories say what a
module is about and nothing else.

Keeping that in one place matters because it changes over time. If `steam.nix`
moves from `nixos.josef-nd1-gpu0` into some later `nixos.gaming` bundle, only the
aggregate name changes; the file stays in `modules/steam.nix` where you would
look for it. A folder such as `opt-in/` would have to be reorganised on every
re-bundling, and would quietly go stale when it wasn't.

`modules/hosts/` is the one deliberate exception, on the grounds that a file
named after a machine can never be reused by a different one, so its path can
safely say so.

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

`vars` is a typed option; see `modules/core/vars.nix` for the full set. Only
`user.name`, `user.full_name`, `user.email` and `git.dotfiles` are required;
everything else has a default, and a missing key gives a named option error
rather than a stray `attribute ... missing`. The type is freeform, so you can
keep your own private keys in the same attrset.

To drop something from the base, use the module system rather than forking.
Base modules are written `enable`-style:

```nix
{lib, ...}: {
  home-manager.users.jhofer.programs.k9s.enable = lib.mkForce false;
}
```

`base.lib` additionally exposes `mkHome`, `mkDotPath` and `mkOpAgentSock`.
