{
  pkgs,
  baseLib,
  ...
}: let
  opAgentSock = baseLib.mkOpAgentSock pkgs;
in {
  home.file.".config/1Password/ssh/agent.toml".source = ./1password-agent.toml;

  programs.ssh = {
    settings = {
      # GitHub
      "github.com" = {
        User = "git";
        IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC K8s
      "*.k8*.jhofer.*" = {
        User = "josef";
        ProxyCommand = "none";
        IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC Stuff
      "10.1.1.* 10.2.2.* 136.* 2a01:4f8:171:188a::* *.jhofer.* *.cafe.local" = {
        User = "root";
        ProxyCommand = "none";
        IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC AWS
      "*.amazonaws.com" = {
        User = "ubuntu";
        ProxyCommand = "none";
        IdentityAgent = ''"${opAgentSock}"'';
      };
    };
  };
}
