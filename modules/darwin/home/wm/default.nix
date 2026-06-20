{
  pkgs,
  lib,
  vars,
  inputs,
  ...
}: {
  imports = [
    inputs.agate.homeManagerModules.default
  ];

  services.agate = {
    enable = true;
    config = builtins.readFile ./agate.lua;
  };
}
