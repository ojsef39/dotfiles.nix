{
  flake.modules.homeManager.personal = {vars, ...}: {
    programs.lazygit.settings.customCommands = [
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
    ];

    programs.git = {
      settings = {
        credential.helper = "!gh auth git-credential";
        # GHQ roots
        "ghq \"https://github.com/\"" = {
          vcs = "git";
          root = "~/${vars.git.ghq}";
        };
        "ghq \"https://gitlab.com/\"" = {
          vcs = "git";
          root = "~/${vars.git.ghq}";
        };
        "ghq \"https://gitlab.die-linke.de/\"" = {
          vcs = "git";
          root = "~/${vars.git.ghq}";
        };
      };
    };
  };
}
