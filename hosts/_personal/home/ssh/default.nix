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

      # JHC grafana kiosk
      "grafana-kiosk-rpi*.*.jhofer.lan" = {
        User = "grafana";
        IdentityAgent = ''"${opAgentSock}"'';
      };

      # JHC CMC
      "bc?-cmc.*.jhofer.lan" = {
        User = "service";
        IdentityAgent = ''"${opAgentSock}"'';
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
        HostKeyAlgorithms = "+ssh-rsa";
        PubkeyAcceptedAlgorithms = "+ssh-rsa";
      };

      # JHC Stuff
      "*.jhofer.* !bc?-cmc.*.jhofer.lan !grafana-kiosk-rpi*.*.jhofer.lan" = {
        User = "root";
        ProxyCommand = "none";
        IdentityAgent = ''"${opAgentSock}"'';
      };
    };
  };
}
