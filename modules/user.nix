{
  flake.modules.generic.base = {
    pkgs,
    vars,
    lib,
    ...
  }: {
    users =
      {
        users.${vars.user.name} =
          {
            shell = pkgs.fish;
            description = vars.user.full_name;
          }
          # uid needs to be set for mac because mac management
          # uses the default 501 user id for its admin user
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            inherit (vars.user) uid;
          }
          # NixOS requires isNormalUser and group membership
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            isNormalUser = true;
            extraGroups = [
              "networkmanager"
              "wheel"
            ];
          };

        # nix-darwin requires knownUsers for declarative user management
        # must use optionalAttrs, not mkIf — mkIf still registers the option definition
        # which causes NixOS to error because users.knownUsers doesn't exist there
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        knownUsers = ["${vars.user.name}"];
      };

    environment.shells = [pkgs.fish];
  };
}
