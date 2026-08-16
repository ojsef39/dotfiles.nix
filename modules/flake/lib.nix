_: {
  # Also published as the flake's `lib` output for downstream use.
  flake.lib = rec {
    # Return the 1Password SSH agent socket path for the given platform.
    # Usage: baseLib.mkOpAgentSock pkgs
    mkOpAgentSock = pkgs:
      if pkgs.stdenv.isDarwin
      then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else "~/.1password/agent.sock";

    # Build the home directory path for the given platform.
    # Usage: baseLib.mkHome vars pkgs
    mkHome = vars: pkgs:
      if pkgs.stdenv.isDarwin
      then "/Users/${vars.user.name}"
      else "/home/${vars.user.name}";

    # Build the absolute dotfiles repository path for the given platform.
    # Usage: baseLib.mkDotPath vars pkgs
    mkDotPath = vars: pkgs: "${mkHome vars pkgs}/${vars.git.ghq}/${vars.git.dotfiles}";
  };
}
