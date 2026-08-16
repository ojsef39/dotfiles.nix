{
  config,
  inputs,
  ...
}: let
  name = "josef-nd1-gpu0";
  m = config.flake.modules;
in {
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      m.nixos.base
      {networking.hostName = name;}
      {vars = import ../../vars/personal.nix;}
      m.generic.personal
      m.nixos.${name}
      (
        {vars, ...}: {
          home-manager.users.${vars.user.name}.imports = [
            m.homeManager.personal
            m.homeManager.${name}
          ];
        }
      )
    ];
  };
}
