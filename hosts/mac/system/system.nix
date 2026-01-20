{
  config,
  vars,
  ...
}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
#  See your own values with for example: `defaults read com.apple.dock tilesize`
#
###################################################################################
let
  hmUser = config.home-manager.users.${vars.user.name};
  hmApps = "${hmUser.home.homeDirectory}/${hmUser.targets.darwin.copyApps.directory}";
in {
  system = {
    defaults = {
      dock = {
        # tilesize = 62; # Just so i know the before value
        # largesize = 64; # Just so i know the before value
        persistent-apps = [
          "/Applications/Arc.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/Applications/WhatsApp.app"
          "/System/Applications/Messages.app"
          "${hmApps}/Vesktop.app"
          "/Applications/Nix Apps/Obsidian.app"
          "/Applications/Things3.app"
          "/Applications/Linear.app"
          "${hmApps}/kitty.app"
          "/Applications/Nix Apps/UTM.app"
          "/Applications/Nix Apps/Moonlight.app"
          "${hmApps}/Spotify.app"
          # "/System//Applications/Music.app"
          "/Applications/Reeder.localized/Reeder.app"
          "/System//Applications/System Settings.app"
          "/Applications/Yubico Authenticator.app"
          "/Applications/Claude.app"
        ];
      };
    };
  };
}
