{
  config,
  inputs,
  ...
}: {
  # Exported modules must be self-contained: a downstream flake importing
  # `base.modules.darwin.base` should not also have to hand `inputs` and
  # `baseLib` back through `specialArgs`. `inputs` here is *this* flake's input
  # set, closed over at eval time, which is what base modules need to resolve —
  # not whatever the consumer happens to call things.
  flake.modules.generic.base = {
    _module.args = {
      inherit inputs;
      baseLib = config.flake.lib;
    };
  };
}
