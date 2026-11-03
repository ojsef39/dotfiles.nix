{
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: {
    ## GHQ -> This must run after the linkGeneration to make sure gitconfig with ghq settings is set
    home.activation = {
      ghqGetRepos = lib.hm.dag.entryAfter ["linkGeneration"] ''
        export PATH=$PATH:/usr/bin:${pkgs.git}/bin
        ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/dotfiles.nix 2>&1 | grep -E "update|error:" || true
      '';
      # TODO: re-add work repos (nix-work, …) once the new work forge is set up.
      # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/2459
      # The old block keyed off the previous employer's `L???-*` hostnames.
    };
  };
}
