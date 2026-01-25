rec {
  user = {
    name = "josefhofer";
    full_name = "Josef Hofer";
    email = "me@jhofer.de";
    uid = 501;
  };
  git = {
    ghq = "CodeProjects";
    callbacks = {
      "gitlab.die-linke.de" = ''require("gitlinker.hosts").get_gitlab_type_url'';
    };
    url = "";
    lazy = {
      # authorColors = {
      #   "test[bot]" = "#f4dbd6"; # Rosewater
      #   "dependabot[bot]" = "#f4dbd6"; # Rosewater
      # };
    };
    nix = "/Users/${user.name}/${git.ghq}/github.com/ojsef39/dotfiles.nix";
  };
  kitty.project_selector = "~/.config";
  cache.community = true;
  is_vm = false;
}
