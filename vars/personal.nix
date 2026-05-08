rec {
  user = {
    name = "josefhofer";
    full_name = "Josef Hofer";
    email = "me@jhofer.de";
    uid = 501;
  };
  git = {
    ghq = "CodeProjects";
    dotfiles = "github.com/ojsef39/dotfiles.nix";
    lazy = {
      # authorColors = {
      #   "test[bot]" = "#f4dbd6"; # Rosewater
      #   "dependabot[bot]" = "#f4dbd6"; # Rosewater
      # };
    };
    customServices = [
      {
        domain = "gitlab.die-linke.de";
        provider = "gitlab";
      }
    ];
  };
  kitty.project_selector = "~/.config";
  cache.community = true;
  masApps.enable = false;
}
