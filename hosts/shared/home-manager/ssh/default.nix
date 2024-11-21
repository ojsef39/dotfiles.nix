{ lib, vars, ... }: {
  programs.ssh = {
    enable = lib.mkDefault true;
    
    includes = [
      ##TODO: Reconfigure this when i know what i want to use where
      "/Users/${vars.user}/.colima/ssh_config"
    ];

    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
    };
  };
}
