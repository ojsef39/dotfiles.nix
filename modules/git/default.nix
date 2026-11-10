{
  flake.modules.homeManager.base = {
    lib,
    pkgs,
    vars,
    config,
    ...
  }: let
    customServices = vars.git.customServices;
    lazygitServices = builtins.listToAttrs (
      map (s: {
        name = s.domain;
        value = "${s.provider}:${s.domain}";
      })
      customServices
    );
  in {
    home = {
      activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        rm -f ~/.gitconfig
      '';
    };

    programs = {
      git = {
        enable = lib.mkDefault true;
        lfs.enable = lib.mkDefault true;

        signing = lib.mkIf (vars.git.signingKey != null) {
          key = vars.git.signingKey;
          signByDefault = true;
          format = "ssh";
          signer =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Applications/Nix Apps/1Password.app/Contents/MacOS/op-ssh-sign"
            else "${pkgs._1password-gui}/bin/op-ssh-sign";
        };

        settings = {
          user = {
            name = "${vars.user.full_name}";
            email = "${vars.user.email}";
          };

          init.defaultBranch = "main";
          ghq.root = "~/${vars.git.ghq}";
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
            amend = "commit --amend -m";
            br = "branch";
            ca = "commit -am";
            cm = "commit -m";
            co = "checkout";
            dc = "diff --cached";
            foreach = "submodule foreach";
            ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
            ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
            mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
            redate-unpushed ="rebase -f --reset-author-date @{u}";
            release-notes = "!f() { git log \"$1..main\" --no-merges --pretty=format:'* %s'; }; f";
            root = "rev-parse --show-toplevel";
            st = "status";
            update = "submodule update --init --recursive";
          };
        };
      };

      delta = {
        enable = lib.mkDefault true;
        enableGitIntegration = true;
        options = {
          # delta takes a space-separated feature list, but the catppuccin port
          # also defines `features`; combine them instead of losing either.
          features = lib.mkForce "side-by-side catppuccin-${config.catppuccin.delta.flavor}";
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
          services = lazygitServices;
          customCommands = [
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
            border = "rounded";
            nerdFontsVersion = 3;
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
              authorColors =
                {
                  "${vars.user.full_name}" = "#ee99a0"; # Maroon
                  "jhcloud-bot" = "#f4dbd6"; # Rosewater
                  "renovate[bot]" = "#f4dbd6"; # Rosewater
                  "*" = "#b7bdf8"; # Lavender
                }
                // vars.git.lazy.authorColors;
            };
          };
        };
      };
    };
  };
}
