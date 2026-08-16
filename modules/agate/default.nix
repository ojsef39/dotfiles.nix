{
  flake.modules.homeManager.darwin = {inputs, ...}: {
    imports = [
      inputs.agate.homeManagerModules.default
    ];

    services.agate = {
      enable = true;
      config = builtins.readFile ./init.lua;
    };
  };
}
