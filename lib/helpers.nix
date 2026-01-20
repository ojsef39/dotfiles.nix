{nixpkgs}: let
  # Helper to support all standard flake systems
  forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
in {
  inherit forAllSystems;

  # Create an overlay that exposes packages with custom vars
  # Usage: nixpkgs.overlays = [(base.lib.makeOverlay vars)];
  makeOverlay = vars: _final: prev:
    import ../packages {
      pkgs = prev;
      inherit vars;
    };

  # Create packages output for all systems with custom vars
  # Usage: packages = base.lib.makePackages vars;
  makePackages = vars:
    forAllSystems (system: let
      pkgs = import nixpkgs {localSystem = system;};
    in
      import ../packages {
        inherit pkgs vars;
      });
}
