{
  lib,
  vars,
  ...
}: {
  home = {
    activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f ~/.gitconfig
    '';
  };

  programs = {
    git = {
      enable = lib.mkDefault true;
      lfs.enable = lib.mkDefault true;

      settings = {
        user = {
          name = "${vars.user.full_name}";
          email = "${vars.user.email}";
        };

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

        alias = {
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
      };
    };

    delta = {
      enable = lib.mkDefault true;
      enableGitIntegration = true;
      options = {
        features = "side-by-side";
      };
    };
    lazygit = {
      enable = true;
      # package = pkgs.buildGoModule rec {
      #   pname = "lazygit";
      #   version = "unstable-2025-07-06";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "jesseduffield";
      #     repo = "lazygit";
      #     # pinned to master branch (update-nix-fetchgit-all)
      #     rev = "1d8073075710fe7998ebd1a37857639757f38c7b"; # master
      #     sha256 = "1plx37vwwbdc56ahhyafimdnr4b4241dhklcbmy9460hqjjdmf9n";
      #   };
      #   vendorHash = null;
      #   doCheck = false;
      #   ldflags = [ "-X main.version=${version}" "-X main.buildSource=nix" ];
      #   meta = with pkgs.lib; {
      #     description = "Simple terminal UI for git commands";
      #     homepage = "https://github.com/jesseduffield/lazygit";
      #     license = licenses.mit;
      #     mainProgram = "lazygit";
      #   };
      # };
      settings = {
        notARepository = "quit";
        git.overrideGpg = true;
        customCommands = [
          # AI Commit using opencode
          {
            key = "C";
            command = "git commit -m '{{ .Form.title }}'";
            context = "files";
            loadingText = "Generating commit messages...";
            prompts = [
              {
                # command = ''/bin/bash -c "git diff HEAD | opencode run --model 'github-copilot/github-copilot/gpt-4.1' 'Generate a conventional commit title from the following git diff:' {}" '';
                key = "title";
                type = "input";
                suggestions.command = ''/bin/bash -c "git diff HEAD | opencode run --model 'github-copilot/gpt-4.1' 'Generate a set of conventional commit titles from the following git diff, separated by new lines! Do not return anything except the commits:' {}" '';
                title = "Commit Message:";
              }
            ];
          }
          {
            key = "p";
            prompts = [
              {
                type = "input";
                title = "PR id:";
              }
            ];
            command = "gh pr checkout {{index .PromptResponses 0}}";
            context = "localBranches";
            loadingText = "Checking out PR...";
          }
          {
            key = "v";
            context = "localBranches";
            loadingText = "Checking out GitHub Pull Request...";
            command = "gh pr checkout {{.Form.PullRequestNumber}}";
            prompts = [
              {
                type = "menuFromCommand";
                title = "Which PR do you want to chekout?";
                key = "PullRequestNumber";
                command = ''
                  gh pr list --json number,title,headRefName,updatedAt --template '{{`{{range .}}{{printf "#%v: %s - %s (%s)" .number .title .headRefName (timeago .updatedAt)}}{{end}}`}}'
                '';
                filter = "#(?P<number>[0-9]+): (?P<title>.+) - (?P<ref_name>[^ ]+).*";
                valueFormat = "{{.number}}";
                labelFormat = ''
                  {{"#" | black | bold}}{{.number | white | bold}} {{.title | yellow | bold}}{{" [" | black | bold}}{{.ref_name | green}}{{"]" | black | bold}}
                '';
              }
            ];
          }
        ];
        gui = {
          theme = {
            activeBorderColor = [
              "#8aadf4"
              "bold"
            ];
            inactiveBorderColor = ["#a5adcb"];
            optionsTextColor = ["#8aadf4"];
            selectedLineBgColor = ["#363a4f"];
            cherryPickedCommitBgColor = ["#494d64"];
            cherryPickedCommitFgColor = ["#8aadf4"];
            unstagedChangesColor = ["#ed8796"];
            defaultFgColor = ["#cad3f5"];
            searchingActiveBorderColor = ["#eed49f"];
          };
          authorColors =
            {
              "${vars.user.full_name}" = "#ee99a0"; # Maroon
              "jhcloud-bot" = "#f4dbd6"; # Rosewater
              "renovate[bot]" = "#f4dbd6"; # Rosewater
              "*" = "#b7bdf8"; # Lavender
            }
            // (vars.git.lazy.authorColors or {});
        };
      };
    };
  };
}
