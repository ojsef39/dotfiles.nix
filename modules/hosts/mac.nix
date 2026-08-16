{
  config,
  inputs,
  ...
}: let
  m = config.flake.modules;
in {
  # Personal macOS configuration.
  #
  # No specialArgs: `vars`, `inputs` and `baseLib` all come from the imported
  # modules themselves (see ../wiring/args.nix and ../wiring/vars.nix). A
  # downstream flake assembles its own host exactly like this.
  flake.darwinConfigurations.mac = inputs.darwin.lib.darwinSystem {
    modules = [
      m.darwin.base
      {nixpkgs.hostPlatform = "aarch64-darwin";}
      {vars = import ../../vars/personal.nix;}
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
