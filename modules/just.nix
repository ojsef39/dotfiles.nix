{
  # The justfile is generic over the flake it runs in ($NIX_GIT_PATH, hostname),
  # so downstream flakes import it instead of copying it:
  #   import '~/.config/just/nix.just'
  flake.modules.homeManager.base = _: {
    xdg.configFile = {
      "just/nix.just".source = ../justfile;
      "just/scripts".source = ../scripts;
    };
  };
}
