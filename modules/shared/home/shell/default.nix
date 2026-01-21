{
  pkgs,
  lib,
  vars,
  ...
}: {
  imports = [
    ./tmux.nix
    ./fastfetch.nix
    ./yazi.nix
  ];

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
    nodejs
    python3
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
      ghql = "/Users/${vars.user.name}/.config/kitty/scripts/project_selector.sh --no-nvim";
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

    interactiveShellInit = ''
      # Environment variables
      set -gx EDITOR nvim
      set -gx GCL_CONTAINER_EXECUTABLE podman
      set -gx GCL_MAX_JOB_NAME_PADDING 30
      set -gx GCL_TIMESTAMPS true
      set -gx NIX_GIT_PATH "${vars.git.nix}"
      set -gx NODE_EXTRA_CA_CERTS /opt/homebrew/etc/ca-certificates/cert.pem
      set -gx PYTHON /usr/bin/python3
      set -gx SSL_CERT_FILE (command -v brew >/dev/null && brew --prefix)/etc/ca-certificates/cert.pem
      set -gx REQUESTS_CA_BUNDLE $SSL_CERT_FILE
      set -gx NIX_SSL_CERT_FILE $SSL_CERT_FILE
    '';

    # Essential functions that can't be replaced with abbreviations
    functions = {
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
        /usr/bin/man -k . 2>/dev/null | SKIP_FF=1 fzf --preview 'man {1}' --preview-window=right:70%:wrap | awk '{print $1}' | xargs man
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
        git branch $argv || true && git switch $argv && gh pr create && gh pr merge -d && git pull
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

        # 1. Unload the service properly
        sudo launchctl unload /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
        echo "Unloaded nix daemon service"

        # 2. Kill any remaining processes
        sudo pkill -9 -f nix-daemon
        echo "Killed all nix-daemon processes"

        # 3. Bootstrap the service back
        sudo launchctl bootstrap system /Library/LaunchDaemons/systems.determinate.nix-daemon.plist
        echo "Bootstrapped nix daemon service"

        sleep 2
        if test -S /nix/var/nix/daemon-socket/socket
          echo "✅ Nix daemon restarted successfully"
        else
          echo "❌ Daemon socket not found"
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
    };

    plugins = with pkgs.fishPlugins; [
      {
        name = "macos";
        inherit (macos) src;
      }
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
          rev = "521560ce2075ca757473816aa31914215332bac9";
          sha256 = "016610i27mz2rk400x7fw1s7g22sbpahdmd4dj2rymms577xs9g4";
        }
        + "/themes/Catppuccin Macchiato.theme"
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

    # Tide configuration (activate after installation)
    activation.configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Launch a kitty overlay terminal to configure tide without disturbing the current session
      ${pkgs.kitty}/bin/kitten @ launch --type=overlay --title="Tide Configuration" --copy-env --env SKIP_FF=1 ${pkgs.fish}/bin/fish -c "
        # Configure tide with initial settings
        set tide_output (tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Many icons' --transient=Yes 2>&1)

        if string match -q '*Invalid*' \$tide_output
          echo 'There was an issue with Tide configuration:'
          echo \$tide_output
          read -n 1 -P \"Press any key to quit \" key_pressed
        else
          echo 'Tide configuration complete. Window will close in 1 second.'
          sleep 1
        end
      "
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
}
