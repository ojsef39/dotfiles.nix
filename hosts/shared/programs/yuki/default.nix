{ pkgs, lib, vars, ... }: {
  home.file.".config/yuki/config.conf".source = ./config.conf;
}
