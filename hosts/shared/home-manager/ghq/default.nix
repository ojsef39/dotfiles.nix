{ pkgs, lib, vars, ... }:
{
  ## GHQ -> This must run after the linkGeneration to make sure gitconfig with ghq settings is set
  home.activation = {
    ghqGetRepos = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      export PATH=$PATH:/usr/bin
      ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/commit-oracle 2>&1 | grep -E "update|error:" || true
      ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/nix-base 2>&1 | grep -E "update|error:" || true
      export PATH=$PATH:/bin/hostname
      hostname=$(/bin/hostname)
      if [[ $hostname == L???-* ]]; then
        ${pkgs.ghq}/bin/ghq get -u https://${vars.git.url}/${vars.user.name}/nix-work 2>&1 | grep -E "update|error:" || true
        ${pkgs.ghq}/bin/ghq get -u https://${vars.git.url}/${vars.user.name}/renovate-dependency-summary 2>&1 | grep -E "update|error:" || true
      else
        ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/nix-personal 2>&1 | grep -E "update|error:" || true
      fi
    '';
  };
}
