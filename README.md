# nix-base

My public nix base configuration (Mac+Linux) i use in my private personal and work configurations.

## Usage

Import with:

```nix
  inputs = {
    # rest of your inputs
    base.url = "github:ojsef39/nix-base";
  };
```

Use like:

```nix
  outputs = { self, nixpkgs, darwin, home-manager, base }: {
    darwinConfigurations = {
      "mac" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";  # or x86_64-darwin
        modules = [
          base.sharedModules
          base.macModules
          # Custom Mac-specific shell customizations
          {
```
