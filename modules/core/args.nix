{
  config,
  inputs,
  ...
}: {
  # So a consumer never has to pass these back through `specialArgs`.
  # `inputs` is *this* flake's set, which is what base modules must resolve.
  flake.modules.generic.base = {
    _module.args = {
      inherit inputs;
      baseLib = config.flake.lib;
    };
  };
}
