{vars, ...}: {
  programs.git = {
    settings = {
      credential.helper = "!gh auth git-credential";
      # GHQ roots
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
    };
  };
}
