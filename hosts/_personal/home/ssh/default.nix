{
  pkgs,
  baseLib,
  ...
}: let
  opAgentSock = baseLib.mkOpAgentSock pkgs;
in {
  home.file.".config/1Password/ssh/agent.toml".source = ./1password-agent.toml;

  programs.ssh = {
    matchBlocks = {
      # GitHub
      "github.com" = {
        user = "git";
        extraOptions.IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC K8s
      "*.k8*.jhofer.*" = {
        user = "josef";
        proxyCommand = "none";
        extraOptions.IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC Stuff
      "10.1.1.* 10.2.2.* 136.* 2a01:4f8:171:188a::* *.jhofer.* *.cafe.local" = {
        user = "root";
        proxyCommand = "none";
        extraOptions.IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC AWS
      "*.amazonaws.com" = {
        user = "ubuntu";
        proxyCommand = "none";
        extraOptions.IdentityAgent = ''"${opAgentSock}"'';
      };
    };
  };
}
