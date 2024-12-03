{ lib, vars, ... }: {
  programs.ssh = {
    enable = lib.mkDefault true;
    
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
          UseKeychain = "yes";
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
    };
  };
}
