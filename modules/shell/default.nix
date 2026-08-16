{
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    vars,
    config,
    baseLib,
    ...
  }: {
    # Required packages
    home.packages = with pkgs; [
      age
      coreutils
      cowsay
      eza
      fortune
      fzf
      git
      gping
      jhcode
      nodejs
      python3
      send-away
      send-cooking
      sops
      tmux
      tree
      wtfis
      yarn
      zoxide
    ];

    programs.fish = {
      enable = lib.mkDefault true;

      # Aliases - direct replacements for commands
      shellAliases = {
        rsync = "rsync -avz --progress";
        unix = "just -f $NIX_GIT_PATH/justfile u";
        snix = "just -f $NIX_GIT_PATH/justfile";
        ghql = "${config.xdg.configHome}/kitty/scripts/project_selector.sh --no-nvim";
        cachix_login = ''echo "$(op read op://Personal/cachix_ojsef39/password)" | cachix authtoken --stdin'';
        ls = "eza --icons --git --header";
        cat = "bat";
        tree = "eza --icons --git --header --tree";
        lg = "lazygit";
        c = "clear";
        d = "devenv";
        k = "kubectl";
        n = "nvim";
        r = "reset";
        x = "exit";
      };

      # Abbreviations - expand as you type them
      shellAbbrs = {
        diffc = "diff -u -a";
        diffn = "nvim -d";
      };

      interactiveShellInit =
        ''
          # Environment variables
          set -gx EDITOR nvim
          set -gx GCL_CONTAINER_EXECUTABLE podman
          set -gx GCL_MAX_JOB_NAME_PADDING 30
          set -gx GCL_TIMESTAMPS true
          set -gx NIX_GIT_PATH "${baseLib.mkDotPath vars pkgs}"
          set -gx NH_SHOW_ACTIVATION_LOGS 1
        ''
        + lib.optionalString pkgs.stdenv.isDarwin ''
          # macOS: nix config name is always "mac" regardless of hostname
          set -gx NIX_CONFIG_NAME mac

          # macOS: make tools trust the homebrew CA bundle
          set -gx PYTHON /usr/bin/python3
          set -gx NODE_EXTRA_CA_CERTS /opt/homebrew/etc/ca-certificates/cert.pem
          set -gx SSL_CERT_FILE (command -v brew >/dev/null && brew --prefix)/etc/ca-certificates/cert.pem
          set -gx REQUESTS_CA_BUNDLE $SSL_CERT_FILE
          set -gx NIX_SSL_CERT_FILE $SSL_CERT_FILE
        '';

      # Essential functions that can't be replaced with abbreviations
      functions = {
        claude-vm = ''
          nix run github:solomon-b/claude-vm -- $argv
        '';

        t = ''
          set session_name (basename $PWD)
          if test -z "$TMUX"
            if tmux has-session -t "$session_name" 2>/dev/null
              tmux attach-session -t "$session_name"
            else
              tmux new-session -s "$session_name"
            end
          else
            echo "Already in a tmux session"
          end
        '';

        _find_nix_base = ''
           # Extract path up to and including workspace/code directory
          set base_path (string replace -r '(/[^/]*(?:workspace|Code)[^/]*)/.*' '$1' $NIX_GIT_PATH)

          set nix_base_path (find "$base_path" -maxdepth 4 -type d -path "*/github.com/*/dotfiles.nix" -print -quit 2>/dev/null)
          if test -n "$nix_base_path"
            echo $nix_base_path
          else
            echo "nix-base repository not found" >&2
            return 1
          end
        '';

        check_repos = ''
          find . -type d -name ".git" | while read -l gitdir
            set repo_dir (dirname "$gitdir")
            if test -n (git -C "$repo_dir" status --porcelain)
              echo "changes in "(string replace -r "^./" "" "$repo_dir")
            end
          end
        '';

        manf = ''
          man -k . 2>/dev/null | SKIP_FF=1 fzf --preview 'man {1}' --preview-window=right:70%:wrap | awk '{print $1}' | xargs man
        '';

        wtf = ''
          # Find the path to nix-base for the sops.yaml file
          set nix_base_path (_find_nix_base)
          if test $status -ne 0
            echo "Error: Could not find nix-base repository" >&2
            return 1
          end

          # Decrypt the file temporarily
          opsops read $HOME/.wtfis.env --sops-file $nix_base_path/.sops.yaml >$HOME/.env.wtfis 2>/dev/null
          set decrypt_status $status

          # Set up cleanup to happen in any case
          function cleanup
            rm -f $HOME/.env.wtfis
          end

          # Only run wtfis if decryption succeeded
          if test $decrypt_status -eq 0
            # Run wtfis with all original arguments
            command wtfis $argv
            set wtfis_status $status
          else
            echo "Error: Failed to decrypt .wtfis.env file" >&2
            set wtfis_status 1
          end

          # Clean up regardless of outcome
          cleanup

          # Return the original status code
          return $wtfis_status
        '';

        cdgit = ''
          set -l git_root (git rev-parse --show-toplevel)
          if test -n "$git_root"
              cd $git_root
          else
              echo "Not in a Git repository."
          end
        '';

        gh_prm = ''
          # Usage: gh_prm <branch> [gh pr create flags] -- [gh pr merge flags]

          set -l branch $argv[1]
          set -l create_flags
          set -l merge_flags
          set -l in_merge 0

          for arg in $argv[2..-1]
            if test "$arg" = "--"
              set in_merge 1
            else if test $in_merge -eq 1
              set merge_flags $merge_flags $arg
            else
              set create_flags $create_flags $arg
            end
          end

          git branch $branch || true && git switch $branch && gh pr create $create_flags && gh pr merge --delete-branch $merge_flags && git pull
        '';

        rm_DS = ''
          find . -name '.DS_Store' -type f -delete
        '';

        temp_dir = ''
          set temp_dir (mktemp -d)
          cd "$temp_dir"
        '';

        nix-restart = ''
          echo "Restarting Nix daemon..."
          if test (uname) = "Darwin"
            sudo launchctl unload /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
            echo "Unloaded nix daemon service"
            sudo pkill -9 -f determinate-nixd
            echo "Killed all nix-daemon processes"
            sudo launchctl bootstrap system /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
            echo "Bootstrapped nix daemon service"
            sleep 2
            if test -S /nix/var/nix/daemon-socket/socket
              echo "Nix daemon restarted successfully"
            else
              echo "Daemon socket not found"
            end
          else
            sudo systemctl restart nix-daemon
            sleep 2
            if systemctl is-active --quiet nix-daemon
              echo "Nix daemon restarted successfully"
            else
              echo "Nix daemon failed to restart"
            end
          end
        '';

        ov = ''
          # Check if we have arguments
          if test (count $argv) -eq 0
              echo "Usage: overlay <command> [args...]"
              return 1
          end

          # Build the command string and get current directory
          set cmd (string join ' ' $argv)
          set current_dir (pwd)

          # Create a more descriptive title
          set title "overlay: $cmd"

          # Launch with kitty overlay
          kitten @launch \
                      --title "$title" \
                      --copy-env \
                      --type=overlay \
                      --cwd="$current_dir" \
                      env SKIP_FF=1 fish -c "
                  $cmd
                  set exit_code \$status
                  if test \$exit_code -ne 0
                      echo 'Command failed with exit code: '\$exit_code
                  end
                  read -n 1 --prompt-str "❯ "
              "
        '';

        nix-render = ''
          # Usage: nix-render <file-path> [flake-path]
          # Renders and prints a home-manager managed file without deploying.
          # Defaults to $NIX_GIT_PATH as the flake. Pass a second arg to use a different flake.
          if test (count $argv) -lt 1
            echo "Usage: nix-render <file-path> [flake-path]"
            echo "Example: nix-render ~/.config/opencode/opencode.json"
            echo "         nix-render ~/.config/foo/bar.json ~/path/to/other-flake"
            return 1
          end

          set -l target $argv[1]
          set -l flake (if test (count $argv) -ge 2; echo $argv[2]; else; echo $NIX_GIT_PATH; end)

          # Normalize path
          set target (string replace -r '^~' $HOME $target)
          if not string match -q '/*' $target
            set target $HOME/$target
          end

          # Determine system config type
          set -l sys (if test (uname) = Darwin; echo darwinConfigurations; else; echo nixosConfigurations; end)

          set -l config_name (test -n "$NIX_CONFIG_NAME" && echo $NIX_CONFIG_NAME || hostname -s)
          set -l hm_base "$flake#$sys.$config_name.config.home-manager.users."(whoami)".home.file"
          # home.file keys may be absolute or relative to $HOME — try both
          set -l rel_target (string replace -r "^$HOME/" "" $target)

          set -l text ""
          set -l drv_path ""
          for key in "\"$target\"" "\"$rel_target\""
            set text (nix eval --raw "$hm_base.$key.text" 2>/dev/null)
            if test -n "$text"; echo $text; return 0; end
            set drv_path (nix eval --raw "$hm_base.$key.source.drvPath" 2>/dev/null)
            if test -n "$drv_path"; break; end
          end

          if test -z "$drv_path"
            echo "error: '$target' not found in home-manager config at $flake" >&2
            return 1
          end

          set -l out_path (nix-store --realise $drv_path 2>/dev/null | tail -1)
          if test -z "$out_path"
            echo "error: failed to build derivation" >&2
            return 1
          end

          cat $out_path
        '';
      };

      plugins = with pkgs.fishPlugins;
        (lib.optionals pkgs.stdenv.isDarwin [
          {
            name = "macos";
            inherit (macos) src;
          }
        ])
        ++ [
          {
            name = "tide";
            inherit (tide) src;
          }
          {
            name = "done";
            inherit (done) src;
          }
        ];

      # We'll store more complex initialization in a separate file
      shellInit = builtins.readFile ./shellInit.fish;
    };

    # Additional program configurations
    programs = {
      fzf = {
        enable = lib.mkDefault true;
        enableFishIntegration = true;
        defaultCommand = "fd --type f"; # Faster than find
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--color=spinner:#f4dbd6,hl:#ed8796"
          "--color=fg:#cad3f5,header:#cad3f5,info:#c6a0f6,pointer:#f4dbd6"
          "--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
        ];
      };
      zoxide = {
        enable = lib.mkDefault true;
        enableFishIntegration = true;
        options = ["--cmd cd"];
      };
      eza = {
        enable = true;
        enableFishIntegration = true;
      };
      bat = {
        enable = true;
        config = {
          theme = "catppuccin-macchiato";
        };
        themes = {
          catppuccin-macchiato = {
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "bat";
              rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
              sha256 = "1y5sfi7jfr97z1g6vm2mzbsw59j1jizwlmbadvmx842m0i5ak5ll";
            };
            file = "themes/Catppuccin Macchiato.tmTheme";
          };
        };
      };
      direnv = {
        enable = true;
        # Fish shell integration is bugged or something:
        # https://github.com/nix-community/home-manager/issues/2357
        # enableFishIntegration = true;
        nix-direnv = {
          enable = true;
        };
        silent = true;
      };
    };

    xdg.configFile = {
      "fish/themes/Catppuccin Macchiato.theme" = {
        text = builtins.readFile (
          pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "fish";
            rev = "5fc5ae9c2ec22eb376cb03ce76f0d262a38960f3";
            sha256 = "19qd700wj0h7k68fs27qa1b1qzs8ccd8rw6qpml3ccyffxhmd8yw";
          }
          + "/themes/catppuccin-macchiato.theme"
        );
      };
    };

    # Ensure tmux plugin manager is installed
    home = {
      file.".tmux/plugins/tpm".source = pkgs.fetchgit {
        url = "https://github.com/tmux-plugins/tpm";
        # version comment so 'update-nix-fetchgit-all' doesnt update this
        rev = "c628645dfa7c4fc16acfb7a73c9d7a98697b472c"; # v3.1.0
        sha256 = "1a05bs5cwhxlmjzhf6m9rmsis2an91qyyysfn2yx2h10lr7jw613";
        leaveDotGit = false;
      };

      activation.configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
        kitty_socket=$(ls /tmp/mykitty-* 2>/dev/null | head -1 || true)
        if [ -n "$kitty_socket" ] && [ -S "$kitty_socket" ] && ${pkgs.kitty}/bin/kitten @ --to "unix:$kitty_socket" ls 2>/dev/null >/dev/null; then
          # Kitty is accessible - run tide configuration (failures will propagate)
          ${pkgs.kitty}/bin/kitten @ --to "unix:$kitty_socket" launch --type=overlay --title="Tide Configuration" --copy-env --env SKIP_FF=1 ${pkgs.fish}/bin/fish -c "
            set tide_output (tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Many icons' --transient=Yes 2>&1)

            if string match -q '*Invalid*' \$tide_output
              echo 'There was an issue with Tide configuration:'
              echo \$tide_output
              sleep 2
              exit 1
            else
              echo 'Tide configuration complete.'
              sleep 1
            end
          "
        else
          # Kitty not accessible (no socket or can't connect)
          echo "Kitty not accessible, skipping tide configuration"
        fi
      '';

      file = {
        # disable last login message
        ".hushlogin".text = "";
        # Create fish_scripts directory for additional scripts
        ".fish_scripts/" = {
          recursive = true;
          source = ./fish_scripts;
        };
        ".wtfis.env" = {
          source = ./wtfis.env;
        };
      };
    };
  };
}
