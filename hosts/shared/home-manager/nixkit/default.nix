{ pkgs, vars, ... }:
{
  programs.default-browser = {
      enable = true;
      browser = "browser"; # browser = Arc
  };
}
