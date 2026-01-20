{vars, ...}: {
  programs.fish = {
    interactiveShellInit = ''
      # Export the talosconfig
      set -gx TALOSCONFIG /tmp/talosconfig

      # Source additional scripts if they exist
      if test -d $HOME/.fish_scripts_local
        for file in $HOME/.fish_scripts_local/*.fish
          source $file
        end
      end
    '';

    # Add the renovate_summary function
    functions = {
      renovate_summary = ''
        # Install tabulate if needed
        pipx install tabulate
        set -l venv_path ~/.local/pipx/venvs/tabulate
        # Set PYTHONPATH to use the site-packages from the virtual environment
        set -l old_pythonpath $PYTHONPATH
        set -gx PYTHONPATH $venv_path/lib/python*/site-packages $PYTHONPATH
        # Add the venv bin path to PATH
        set -l old_path $PATH
        set -gx PATH $venv_path/bin $PATH
        python3 /Users/${vars.user.name}/${vars.git.ghq}/github.com/ojsef39/renovate-dependency-summary-no-config/renovate-summary.py
        # Restore original paths
        set -gx PYTHONPATH $old_pythonpath
        set -gx PATH $old_path
      '';

      renovate_summary_debug = ''
        set -l token (gh auth token)

        if test -z "$token"
            echo "Error: Could not get GitHub token. Make sure you're authenticated with 'gh auth login'"
            return 1
        end

        podman run --rm -it \
            -v $PWD:/usr/src/app \
            -e LOG_LEVEL=debug \
            -e GITHUB_COM_TOKEN=$token \
            renovate/renovate \
            --platform=local
      '';
    };

    shellAliases = {
      talos = "talosctl";
    };
  };

  home = {
    file = {
      ".fish_scripts_local/" = {
        recursive = true;
        source = ./fish_scripts;
      };
    };
  };
}
