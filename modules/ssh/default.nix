{
  flake.modules.homeManager.base = {
    lib,
    pkgs,
    vars,
    baseLib,
    ...
  }: {
    # https://developer.1password.com/docs/ssh/agent/config
    xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (vars.onePassword.sshVaults != []) {
      text = lib.concatMapStringsSep "\n" (vault: ''
        [[ssh-keys]]
        vault = ${builtins.toJSON vault}
      '')
      vars.onePassword.sshVaults;
    };

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
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
            UseKeychain = "yes";
          };
      };
    };
  };
}
