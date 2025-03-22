{ pkgs, lib, vars, ... }:
{
  programs.k9s = {
    enable = lib.mkDefault true;
    settings = {
      k9s = {
        liveViewAutoRefresh = true;
        ui = {
          skin = "catppuccin-macchiato";
          enableMouse = true;
          reactive = true;
        };
        logger = {
          tail = 500;
          buffer = 5000;
          sinceSeconds = -1;
        };
      };
    };
  };
  home.file = {
    "Library/Application Support/k9s/skins/catppuccin-macchiato.yaml" = {
      source = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/k9s/refs/heads/main/dist/catppuccin-macchiato.yaml";
        sha256 = "1wdxway40xzz0kl4phs64h0h9b4xvkgsh7c75w0s9za8az6bf79r";
      };
      force = true;
    };
  };
}
