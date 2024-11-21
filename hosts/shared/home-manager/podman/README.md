# Usage

```nix
{ lib, ... }:
{
  home = {
    activation = {
      podmanSetup = lib.hm.dag.entryAfter ["podmanSetupBase"] ''
        export PATH=/usr/bin:$PATH
        # Your activation script here
    };
  };
}
```
