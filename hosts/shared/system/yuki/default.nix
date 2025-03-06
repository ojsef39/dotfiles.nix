# { pkgs, lib, vars, ... }: {
#   programs.yuki = {
#     enable = true;
#     settings = {
#       system_packages_path = if pkgs.stdenv.isDarwin then "${vars.git.nix}/hosts/darwin/apps.nix" else "${vars.git.nix}/hosts/apps.nix";
#       homebrew_packages_path = "${vars.git.nix}/hosts/darwin/homebrew.nix";
#       auto_commit = true;
#       auto_push = false;
#       install_message = "chore(apps): installed <package> [yuki]";
#       uninstall_message = "chore(apps): removed <package> [yuki]";
#       install_command = "update-nix";
#       uninstall_command = "update-nix";
#       update_command = "update-nix";
#     };
#   };
# }
