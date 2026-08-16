{
  flake.modules.darwin.mac = {
    vars,
    lib,
    ...
  }: {
    # Homebrew for macOS-specific and unavailable packages
    homebrew = {
      taps = [
        {
          name = "doodlescheduling/flux-build";
          clone_target = "https://github.com/DoodleScheduling/flux-build.git";
          trusted = true;
        }
      ];

      # Mac App Store apps
      masApps = lib.mkIf vars.masApps.enable {
        "Book Tracker" = 1496543317;
        "CrystalFetch" = 6454431289;
        "Final Cut Pro" = 424389933;
        "Flighty" = 1358823008;
        "Goodnotes" = 1444383602;
        "Keynote" = 361285480;
        "Motion" = 434290957;
        "Numbers" = 361304891;
        "Pages" = 361309726;
        "Parcel" = 375589283;
        "Pixelmator Pro" = 1289583905;
        "TestFlight" = 899247664;
        # "waifu2x" = 1286485858;
      };

      # Homebrew formulae (CLI tools)
      brews = [
        "Graphviz"
        "expect"
        "iperf3"
        "talosctl"
        # "docx2pdf" #NOTE: Needs tap
      ];

      # macOS-specific apps and those not available/stable in nixpkgs
      casks = [
        "Signal"
        "brooklyn"
        "flux-build"
        "imageoptim"
        "nextcloud"
        "parsec"
      ];
    };
  };
}
