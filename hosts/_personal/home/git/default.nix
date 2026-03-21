{
  pkgs,
  vars,
  ...
}: {
  programs.git = {
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnnOOtnSeqQ3+XjO2jaC5k0pk5BIZVB4YI3KukF4o83";
      signByDefault = true;
    };
    settings = {
      credential.helper = "!gh auth git-credential";
      gpg.format = "ssh";
      "gpg \"ssh\"".program =
        if pkgs.stdenv.isDarwin
        then "/Applications/Nix Apps/1Password.app/Contents/MacOS/op-ssh-sign"
        else "${pkgs._1password-gui}/bin/op-ssh-sign";

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
