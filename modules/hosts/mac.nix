{
  config,
  inputs,
  ...
}: let
  m = config.flake.modules;
in {
  # Personal macOS configuration.
  flake.darwinConfigurations.mac = inputs.darwin.lib.darwinSystem {
    modules = [
      m.generic.base
      m.darwin.base
      {nixpkgs.hostPlatform = "aarch64-darwin";}
      m.generic.personal
      m.darwin.mac
      (
        {vars, ...}: {
          home-manager.users.${vars.user.name}.imports = [
            m.homeManager.personal
          ];
        }
      )
    ];
    specialArgs = {
      vars = import ../../vars/personal.nix;
      baseLib = config.flake.lib;
    };
  };

  # CI variant of `mac`
  flake.darwinConfigurations.mac-ci = config.flake.darwinConfigurations.mac.extendModules {
    modules = [
      (
        {
          vars,
          lib,
          ...
        }: {
          home-manager.users.${vars.user.name}.programs.mac-mouse-fix.enable = lib.mkForce false;
          nixpkgs.overlays = lib.mkAfter [
            (_: prev: {
              kubectl-debug = prev.runCommandLocal "kubectl-debug-ci-stub" {} "mkdir -p $out";
            })
          ];
        }
      )
    ];
  };
}
