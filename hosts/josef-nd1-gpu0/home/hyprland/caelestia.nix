{pkgs, ...}: let
  catppuccin-wallpapers = pkgs.fetchFromGitHub {
    owner = "orangci";
    repo = "walls-catppuccin-mocha";
    rev = "7bfdf10d16ad3a689f9f0cf3a0930da3d1a245a8";
    sha256 = "0bzs76iqhxa53azlayb8rwmaxakwv0fz08lh9dfykh2w4hfikqrp";
  };
in {
  programs.caelestia = {
    enable = true;
    systemd.enable = false; # Started from hyprland directly
    cli = {
      enable = true;
      settings.theme.enableGtk = false;
    };
    settings = {
      bar.status = {
        showBattery = false;
        showMicrophone = true;
        showWifi = false;
      };
      menu.layout = "modern";
      general = {
        idle.timeouts = [];
        apps.terminal = ["ghostty"];
      };
      paths.wallpaperDir = "${catppuccin-wallpapers}";
      theme = {
        preset = "custom";
        fonts = {
          default = "Maple Mono NF";
          icon = "Material Symbols Rounded";
        };
        colors = {
          background = "#24273A"; # base
          backgroundAlt = "#363A4F"; # surface0
          foreground = "#CAD3F5"; # text
          foregroundAlt = "#A5ADCB"; # subtext0
          primary = "#8AADF4"; # blue
          primaryAlt = "#B7BDF8"; # lavender
          secondary = "#C6A0F6"; # mauve
          error = "#ED8796"; # red
          success = "#A6DA95"; # green
          warning = "#EED49F"; # yellow
        };
        rounding = 10;
        blur = true;
      };
    };
  };
}
