{ lib, ... }:
{
  home.activation = {
    killDock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      export PATH=$PATH:/usr/bin
      /usr/bin/killall Dock
    '';
  };
}
