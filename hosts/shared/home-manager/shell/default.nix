{ pkgs, lib, vars, ... }:
{
  imports = [
    ./tmux.nix
    ./yazi.nix
  ];

  # Required packages
  home.packages = with pkgs; [
    age
    coreutils
    eza
    fastfetch
    fzf
    git
    nodejs
    python3
    sops
    tmux
    tree
    yarn
    zoxide
  ];

  programs.fish = {
    enable = lib.mkDefault true;

    # Aliases - direct replacements for commands
    shellAliases = {
      update-nix = "make -C ${vars.git.nix} update";
      select-nix = "make -C ${vars.git.nix} select";
      nhu = "nh darwin switch -u -a -H mac $NIX_GIT_PATH";
      nhb = "nh darwin switch -U base -a -H mac $NIX_GIT_PATH";
      nhd = "nh darwin switch -a -H mac $NIX_GIT_PATH";
      nhc = "nh clean all -a -k 2 -K 14d";
      ghql = "/Users/${vars.user.name}/.config/kitty/scripts/project_selector.sh --no-nvim";
      ls = "eza --icons --git --header";
      cat = "bat";
      tree = "eza --icons --git --header --tree";
      lg = "lazygit";
      k = "kubectl";
      n = "nvim";
      x = "exit";
    };

    # Abbreviations - expand as you type them
    shellAbbrs = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gp = "git pull";
      gpu = "git push";
      gst = "git status";
      diffc = "diff -u -a";
      diffn = "nvim -d";
    };

    interactiveShellInit = ''
      # Environment variables
      set -gx BAT_THEME Catppuccin Macchiato
      set -gx GCL_CONTAINER_EXECUTABLE podman
      set -gx GCL_MAX_JOB_NAME_PADDING 30
      set -gx GCL_TIMESTAMPS true
      set -gx NIX_GIT_PATH "${vars.git.nix}"
      set -gx NODE_EXTRA_CA_CERTS /opt/homebrew/etc/ca-certificates/cert.pem
      set -gx PYTHON /usr/bin/python3
      set -gx REQUESTS_CA_BUNDLE (command -v brew >/dev/null && brew --prefix)/etc/ca-certificates/cert.pem
      set -gx SSL_CERT_FILE (command -v brew >/dev/null && brew --prefix)/etc/ca-certificates/cert.pem
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

      check_repos = ''
        find . -type d -name ".git" | while read -l gitdir
          set repo_dir (dirname "$gitdir")
          if test -n (git -C "$repo_dir" status --porcelain)
            echo "changes in "(string replace -r "^./" "" "$repo_dir")
          end
        end
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
      defaultCommand = "fd --type f";  # Faster than find
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
    };
  };

  xdg.configFile = {
      "fish/themes/Catppuccin Macchiato.theme" = {
          text = builtins.readFile (pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/catppuccin/fish/refs/heads/main/themes/Catppuccin%20Macchiato.theme";
              sha256 = "sha256-WFGzRDaC8zY96w9QgxIbFsAKcUR6xjb/p7vk7ZWgeps=";
          });
      };
      "bat/themes/Catppuccin Macchiato.tmTheme" = {
        text = builtins.readFile (pkgs.fetchurl {
          url = "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme";
          sha256 = "sha256-zL18U4AXMO8+gBH3T/HDl8e7OYjIRqUdeeb0i4V7kVI=";
        });
      };
  };

  # Ensure tmux plugin manager is installed
  home = {
    file.".tmux/plugins/tpm".source = pkgs.fetchgit {
      url= "https://github.com/tmux-plugins/tpm";
      rev = "v3.1.0";
      sha256 = "sha256-IxguT6YgQNG9sE5773FIVgkddc2pGge/rLRDzopeBag=";
      leaveDotGit = false;
    };

    # Tide configuration (activate after installation)
    activation.configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Launch a kitty overlay terminal to configure tide without disturbing the current session
      $DRY_RUN_CMD ${pkgs.kitty}/bin/kitten @ launch --type=overlay --title="Tide Configuration" --copy-env --env SKIP_FF=1 ${pkgs.fish}/bin/fish -C "
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
        exit 0
      "
    '';

    # Create fish_scripts directory for additional scripts
    file = {
      ".fish_scripts/" = {
        recursive = true;
        source = ./fish_scripts;
      };
    };
  };
}
