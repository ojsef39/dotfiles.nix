{ lib, ... }:
{
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
          UseKeychain = "yes";
          ForwardAgent = "no";
          Compression = "no";
          ServerAliveInterval = "0";
          ServerAliveCountMax = "3";
          HashKnownHosts = "no";
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
      };
    };
  };
}
