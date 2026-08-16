{
  flake.modules.homeManager.base = _: {
    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
