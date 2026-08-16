{
  config,
  inputs,
  ...
}: let
  name = "JosefsMacBookPro";
  m = config.flake.modules;
in {
  flake.darwinConfigurations.${name} = inputs.darwin.lib.darwinSystem {
    modules = [
      m.darwin.base
      {nixpkgs.hostPlatform = "aarch64-darwin";}
      {
        networking = {
          computerName = name;
          hostName = name;
          localHostName = name;
        };
      }
      {vars = import ../../../vars/personal.nix;}
      m.generic.personal
      m.darwin.${name}
      (
        {vars, ...}: {
          home-manager.users.${vars.user.name}.imports = [
            m.homeManager.personal
          ];
        }
      )
    ];
  };

  # Same config, minus what cannot build on a GitHub runner.
  flake.darwinConfigurations."${name}-ci" = config.flake.darwinConfigurations.${name}.extendModules {
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
