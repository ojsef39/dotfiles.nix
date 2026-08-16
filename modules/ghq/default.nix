{
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    vars,
    ...
  }: {
    ## GHQ -> This must run after the linkGeneration to make sure gitconfig with ghq settings is set
    home.activation = {
      ghqGetRepos = lib.hm.dag.entryAfter ["linkGeneration"] ''
        export PATH=$PATH:/usr/bin:${pkgs.git}/bin
        ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/dotfiles.nix 2>&1 | grep -E "update|error:" || true
        hostname=$(${pkgs.inetutils}/bin/hostname)
        if [[ $hostname == L???-* ]] && [[ -n "${vars.git.url}" ]]; then
          ${pkgs.ghq}/bin/ghq get -u https://${vars.git.url}/${vars.user.name}/nix-work 2>&1 | grep -E "update|error:" || true
          ${pkgs.ghq}/bin/ghq get -u https://${vars.git.url}/${vars.user.name}/renovate-dependency-summary 2>&1 | grep -E "update|error:" || true
        fi
      '';
    };
  };
}
