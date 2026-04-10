{
  vars,
  lib,
  ...
}: {
  # Homebrew for macOS-specific and unavailable packages
  homebrew = {
    taps = [
      "doodlescheduling/flux-build"
    ];

    # Mac App Store apps
    masApps = lib.mkIf (vars.masApps.enable or true) {
      "Book Tracker" = 1496543317;
      "CrystalFetch" = 6454431289;
      "Final Cut Pro" = 424389933;
      "Flighty" = 1358823008;
      "Goodnotes" = 1444383602;
      "Ground News" = 1324203419;
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
      "flux-build"
      "iperf3"
      "talosctl"
      # "docx2pdf" #NOTE: Needs tap
    ];

    # macOS-specific apps and those not available/stable in nixpkgs
    casks = [
      "Signal"
      "brooklyn"
      "imageoptim"
      "nextcloud"
      "parsec"
    ];
  };
}
