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
    signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnnOOtnSeqQ3+XjO2jaC5k0pk5BIZVB4YI3KukF4o83"; # id_ed25519_new
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
  cachix.push = true;
  onePassword.sshVaults = [
    "Personal"
    "JHC"
  ];
  # TODO: masapps disabled?
  # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/2467
  masApps.enable = false;
  nvim.cord.allowList = ["github.com/ojsef39/"];
}
