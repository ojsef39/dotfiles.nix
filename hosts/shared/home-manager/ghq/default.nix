{ pkgs, lib, vars, ... }:
{
  ## GHQ -> This must run after the linkGeneration to make sure gitconfig with ghq settings is set
  home.activation = {
    ghqGetRepos = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      export PATH=$PATH:/usr/bin
      ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/commit-oracle || true
      ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/nix-base || true
      export PATH=$PATH:/bin/hostname
      hostname=$(/bin/hostname)
      if [[ $hostname == L???-* ]]; then
        ${pkgs.ghq}/bin/ghq get -u https://${vars.git.url}/${vars.user}/nix-work || true 
      else
        ${pkgs.ghq}/bin/ghq get -u https://github.com/ojsef39/nix-personal || true 
      fi
    '';
  };
}
