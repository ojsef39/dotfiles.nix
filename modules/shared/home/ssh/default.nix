{
  lib,
  pkgs,
  baseLib,
  ...
}: {
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;

    settings = {
      "*" =
        {
          AddKeysToAgent = "yes";
          IdentityAgent = ''"${baseLib.mkOpAgentSock pkgs}"'';
          ForwardAgent = "no";
          Compression = "no";
          ServerAliveInterval = "0";
          ServerAliveCountMax = "3";
          HashKnownHosts = "no";
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          UseKeychain = "yes";
        };
    };
  };
}
