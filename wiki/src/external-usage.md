# External Usage

This flake exposes its modules for consumption by other configurations, allowing
a layered approach where `dotfiles.nix` provides the base.

## Exported modules

Modules are published as `flake.modules.<class>.<name>`. Only the `base`
aggregates are part of the public surface:

| Aggregate | Scope |
| --- | --- |
| `generic.base` | cross-platform system config |
| `darwin.base` | nix-darwin system + home-manager wiring |
| `nixos.base` | NixOS system + home-manager wiring |
| `homeManager.base` | cross-platform home config |
| `homeManager.darwin` / `homeManager.nixos` | platform-specific home config |

`darwin.base` and `nixos.base` each import `generic.base` and the matching
`homeManager.*` aggregates, so a consumer imports exactly **one** module.

Everything else (`generic.personal`, `homeManager.personal`, the per-host
aggregates, and opt-in capabilities such as `nixos.nvidia`) is deliberately
unreachable from `*.base` and never reaches a downstream configuration.

`lib` additionally exposes `mkHome`, `mkDotPath` and `mkOpAgentSock`.

## Example consumption

Point `nixpkgs` at this flake so you don't end up with two nixpkgs in one
closure, then import the aggregate and supply `vars`:

```nix
{
  inputs = {
    base.url = "github:ojsef39/dotfiles.nix";
    nixpkgs.follows = "base/nixpkgs";
    darwin.follows = "base/darwin";
  };

  outputs = {base, darwin, ...}: {
    darwinConfigurations.workMac = darwin.lib.darwinSystem {
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
        ./work-specific-config.nix
      ];
    };
  };
}
```

There is **no `specialArgs`**: `vars`, `inputs` and `baseLib` are supplied by the
imported modules themselves.

`vars` is a typed option (see `modules/core/vars.nix`). Only `user.name`,
`user.full_name`, `user.email` and `git.dotfiles` are required; everything else
has a default, and a missing key produces a named option error rather than a
stray `attribute ... missing`. The type is freeform, so a consumer can keep its
own private keys in the same attrset.

To drop something from the base, use the module system rather than forking.
Base modules are written `enable`-style:

```nix
{lib, ...}: {
  home-manager.users.jhofer.programs.k9s.enable = lib.mkForce false;
}
```

## Remote building

(with 1Password as SSH Agent)

```bash
nix build .#darwinConfigurations.JosefsMacBookPro.system --builders 'ssh://<user>@<ip> x86_64-linux,aarch64-darwin'
```

> [!CAUTION]
> Make sure you ran `sudo ssh <user>@<ip>` first and accept the host key dialog,
> otherwise remote build will fail as that runs as root (nix daemon).
>
> This only works because of `modules/macos/system.nix`:

```nix
{{#include ../../modules/macos/system.nix:remote-builders}}
```
