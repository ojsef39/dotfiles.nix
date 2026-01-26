{
  vars,
  lib,
  ...
}: {
  # Homebrew for macOS-specific and unavailable packages
  homebrew = {
    taps = [];

    # Mac App Store apps
    masApps = lib.mkIf (!vars.is_vm) {
      "Book Tracker" = 1496543317;
      "CrystalFetch" = 6454431289;
      "Final Cut Pro" = 424389933;
      "Goodnotes" = 1444383602;
      "Ground News" = 1324203419;
      "Keynote" = 409183694;
      "Motion" = 434290957;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Parcel" = 639968404;
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
      "imageoptim"
      "parsec"
    ];
  };
}
