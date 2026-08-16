{
  config,
  inputs,
  ...
}: let
  name = "JosefsMacBookPro";
  m = config.flake.modules;
in {
  # Personal macOS configuration.
  #
  # Named after the machine's actual hostname so `nh darwin switch` resolves it
  # without an explicit -H. The hostname is also pinned declaratively below, so
  # the config name and the machine agree by construction.
  #
  # No specialArgs: `vars`, `inputs` and `baseLib` all come from the imported
  # modules themselves (see ../wiring/args.nix and ../wiring/vars.nix). A
  # downstream flake assembles its own host exactly like this.
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
      {vars = import ../../vars/personal.nix;}
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

  # CI variant. Kept under a fixed name rather than tracking the hostname,
  # because CI passes -H explicitly and never runs on the real machine.
  flake.darwinConfigurations.mac-ci = config.flake.darwinConfigurations.${name}.extendModules {
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
