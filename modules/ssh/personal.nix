{
  flake.modules.homeManager.personal = {
    pkgs,
    baseLib,
    ...
  }: let
    opAgentSock = baseLib.mkOpAgentSock pkgs;
    # ssh runs ProxyCommand with $SHELL (fish), so the parameter expansion needs sh.
    kubevirtVm = env: {
      ProxyCommand = "sh -c 'h=\${0%%.vm-${env}}; exec ${pkgs.kubevirt}/bin/virtctl --context admin@talos-${env} -n \${h##*.} port-forward --stdio=true vmi/\${h%%.*} %p' %h";
    };
  in {
    programs.ssh = {
      settings = {
        # JHC KubeVirt VMs: ssh <user>@<vm>.<namespace>.vm-live
        "*.vm-dev" = kubevirtVm "dev";
        "*.vm-live" = kubevirtVm "live";

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
  };
}
