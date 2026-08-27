{
  flake.modules.homeManager.personal = {
    lib,
    pkgs,
    vars,
    ...
  }: {
    programs.fish = {
      # mkAfter: personal config must land after the base block
      interactiveShellInit = lib.mkAfter ''
        set -gx TALOSCONFIG /tmp/talosconfig

        # Source additional scripts if they exist
        if test -d $HOME/.fish_scripts_local
          for file in $HOME/.fish_scripts_local/*.fish
            source $file
          end
        end
      '';

      functions = {
        renovate_summary = ''
          pipx install tabulate
          set -l venv_path ~/.local/pipx/venvs/tabulate
          set -l old_pythonpath $PYTHONPATH
          set -gx PYTHONPATH $venv_path/lib/python*/site-packages $PYTHONPATH
          set -l old_path $PATH
          set -gx PATH $venv_path/bin $PATH
          python3 $HOME/${vars.git.ghq}/github.com/ojsef39/renovate-dependency-summary-no-config/renovate-summary.py
          set -gx PYTHONPATH $old_pythonpath
          set -gx PATH $old_path
        '';

        renovate_debug = ''
          set -l token (gh auth token)

          if test -z "$token"
              echo "Error: Could not get GitHub token. Make sure you're authenticated with 'gh auth login'"
              return 1
          end

          LOG_LEVEL=debug GITHUB_COM_TOKEN=$token ${pkgs.renovate}/bin/renovate --platform=local

          # podman run --rm -it \
          #     -v $PWD:/usr/src/app \
          #     -e LOG_LEVEL=debug \
          #     -e GITHUB_COM_TOKEN=$token \
          #     ghcr.io/jhofer-cloud/renovate \
          #     --platform=local
        '';
      };

      shellAliases = {
        talos = "talosctl";
      };
    };

    home.file.".fish_scripts_local/" = {
      recursive = true;
      source = ./fish_scripts_personal;
    };
  };
}
