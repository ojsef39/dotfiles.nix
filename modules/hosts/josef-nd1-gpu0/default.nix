#TODO: Loonix
#Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/515
# - [x] Remove x86_64-darwin support
# - [x] Add basic nixos support
# - [ ] btw plasma graphisch konfigurieren und dann einfach nix run github:nix-community/plasma-manager machen und das spuckt dann eine config aus
# - [ ] Check if everything that should be shared is actually shared (and not duplicated in both mac and nixos config)
#  - [x] !! DONT POLLUTE WORK MACHINES USING EXPOSED MODULES
#        -> personal config now goes in the `*.personal` aggregates, which are
#           unreachable from the exported `*.base` ones. See README.md.
#  - [!] https://github.com/niri-wm/niri -> doesnt work with sunshine https://github.com/niri-wm/niri/discussions/714
#  - [x] Hyperland + https://github.com/caelestia-dots/shell
#  - [?] Try to recreate bazzite?
#  - [x] Use cachy kernel
#  - [ ] https://github.com/kimjongbing/nix-proton-cachyos (https://reddit.com/r/cachyos/comments/1rdsxk1/_/o77l4f7/?context=1)
#  - [ ] https://github.com/beeradmoore/dlss-swapper / https://wiki.cachyos.org/configuration/gaming/#forcing-the-latest-dlss-preset
# - [ ] give github stars to whatever i used
# - [x] CI
# - [ ] Docs
# - [ ] Rework keybinds (use heyperkey on mac, look at https://wiki.hypr.land/Configuring/Binds/#keysym-combos for linux)
# labels: enhancement, os:nix
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
      {vars = import ../../../vars/personal.nix;}
      m.generic.personal

      # Optional capabilities this machine has
      m.nixos.nvidia
      {gpuType.rtx4080 = true;}

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
