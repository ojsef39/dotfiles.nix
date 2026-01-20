{vars, ...}: {
  programs.git = {
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnnOOtnSeqQ3+XjO2jaC5k0pk5BIZVB4YI3KukF4o83";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "${vars.user.full_name}";
        email = "${vars.user.email}";
      };

      # GHQ configurations
      "ghq \"https://github.com/\"" = {
        vcs = "git";
        root = "~/${vars.git.ghq}";
      };
      "ghq \"https://gitlab.com/\"" = {
        vcs = "git";
        root = "~/${vars.git.ghq}";
      };
      "ghq \"https://gitlab.die-linke.de/\"" = {
        vcs = "git";
        root = "~/${vars.git.ghq}";
      };

      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };
}
