{ lib, vars, ...}:
{
  home = {
    activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -f ~/.gitconfig
    '';
    file."Library/Application Support/lazygit/config.yml".text = ''
      # yaml-language-server: $schema=https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json
      customCommands:
        - key: <c-g>
          description: Pick LLM commit
          loadingText: "waiting for LLM to generate commit messages..."
          command: clear && export EDITOR=nvim && commit-oracle.sh
          context: files
          subprocess: true
      git:
        overrideGpg: true
      gui:
        theme:
          activeBorderColor:
            - "#8aadf4"
            - bold
          inactiveBorderColor:
            - "#a5adcb"
          optionsTextColor:
            - "#8aadf4"
          selectedLineBgColor:
            - "#363a4f"
          cherryPickedCommitBgColor:
            - "#494d64"
          cherryPickedCommitFgColor:
            - "#8aadf4"
          unstagedChangesColor:
            - "#ed8796"
          defaultFgColor:
            - "#cad3f5"
          searchingActiveBorderColor:
            - "#eed49f"

        authorColors:
          "${vars.full_name}": "#ee99a0" # Maroon
          "jhcloud-bot": "#f4dbd6" # Rosewater
          "renovate[bot]": "#f4dbd6" # Rosewater
          ${if vars.git.lazy ? authorColors then builtins.replaceStrings ["\n"] ["\n    "] vars.git.lazy.authorColors else ""}
          "*": "#b7bdf8" #Lavender
    '';
  };

  programs.git = {
    enable = lib.mkDefault true;
    lfs.enable = lib.mkDefault true;

    userName = "${vars.full_name}";
    userEmail = "${vars.email}";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = lib.mkDefault true;
      pull.rebase = lib.mkDefault true;

      diff = {
        tool = "nvimdiff";
      };

      difftool = {
        prompt = false;
        trustExitCode = true;
        nvimdiff = {
          cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };
      };

      tag.forceSignAnnotated = lib.mkDefault false;
    };

    aliases = {
      mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
      br = "branch";
      co = "checkout";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m";
      ca = "commit -am";
      dc = "diff --cached";
      amend = "commit --amend -m";
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };

    delta = {
      enable = lib.mkDefault true;
      options = {
        features = "side-by-side";
      };
    };
  };
}
