{inputs, ...}: {
  # Provides `flake.modules.<class>.<name>`, the aggregates this repo publishes.
  imports = [inputs.flake-parts.flakeModules.modules];

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
}
