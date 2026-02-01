# External Usage

This flake exposes its modules for consumption by other configurations (like
`nix-work`), allowing for a layered configuration approach where `dotfiles.nix`
provides the base.

## Exported Modules

- **`sharedModules`**: Core system configuration, packages, and shared Home
  Manager modules.
- **`macModules`**: macOS-specific system modules and settings.

## Output Structure

The flake outputs are structured to be easily consumed:

```nix
outputs = { ... }: {
  sharedModules = [ ... ]; # Base modules
  macModules = [ ... ];    # macOS modules
  lib = { ... };           # Helper library
};
```

## Example: `nix-work` Consumption

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

## Remote building

(with 1Password as SSH Agent)

```bash
nix build .#darwinConfigurations.mac.system --builders 'ssh://<user>@<ip> x86_64-linux,aarch64-darwin'
```

> [!CAUTION]
> Make sure you ran `sudo ssh <user>@<ip>` first and accept the host key dialog,
> otherwise remote build will fail as that runs as root (nix daemon).
>
> This only works because of modules/darwin/system/system.nix:

```nix
{{#include ../../modules/darwin/system/system.nix:104:132}}
```
