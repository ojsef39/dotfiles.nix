{ pkgs, lib, vars, ...}:
{
  home = {
    activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -f ~/.gitconfig
    '';
  };

  programs = { 
    git = {
      enable = lib.mkDefault true;
      lfs.enable = lib.mkDefault true;

      userName = "${vars.user.full_name}";
      userEmail = "${vars.user.email}";

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
    lazygit = {
      enable = true;
      package = pkgs.buildGoModule rec {
        pname = "lazygit";
        version = "unstable-2025-05-29";
        src = pkgs.fetchFromGitHub {
          owner = "jesseduffield";
          repo = "lazygit";
          # pinned to master branch (update-nix-fetchgit-all)
          rev = "8280fdedb72e90ff5169dfe11ef2a92ebfe33551"; # master
          sha256 = "1dgj6z0y03s21i0dhn50xxdhknqgavawd9yzyr3gmxm15gs0m4l5";
        };
        vendorHash = null;
        doCheck = false;
        ldflags = [ "-X main.version=${version}" "-X main.buildSource=nix" ];
        meta = with pkgs.lib; {
          description = "Simple terminal UI for git commands";
          homepage = "https://github.com/jesseduffield/lazygit";
          license = licenses.mit;
          mainProgram = "lazygit";
        };
      };
      settings = {
        notARepository = "quit";
        git.overrideGpg = true;
        customCommands = [
          {
            key = "<c-g>";
            description = "Pick LLM commit";
            loadingText = "waiting for LLM to generate commit messages...";
            command = "clear && export EDITOR=nvim && commit-oracle.sh";
            context = "files";
            output = "terminal";
          }
        ];
        gui = {
          theme = {
            activeBorderColor = ["#8aadf4" "bold"];
            inactiveBorderColor = ["#a5adcb"];
            optionsTextColor = ["#8aadf4"];
            selectedLineBgColor = ["#363a4f"];
            cherryPickedCommitBgColor = ["#494d64"];
            cherryPickedCommitFgColor = ["#8aadf4"];
            unstagedChangesColor = ["#ed8796"];
            defaultFgColor = ["#cad3f5"];
            searchingActiveBorderColor = ["#eed49f"];
          };
          authorColors = {
            "${vars.user.full_name}" = "#ee99a0"; # Maroon
            "jhcloud-bot" = "#f4dbd6"; # Rosewater
            "renovate[bot]" = "#f4dbd6"; # Rosewater
            "*" = "#b7bdf8"; # Lavender
          } // (if vars.git.lazy ? authorColors then vars.git.lazy.authorColors else {});
        };
      };
    };
  };
}
