_: {
  # installed via mod/dw/brew
  targets.darwin.defaults = {
    "com.thelazydeveloper.posturr" = {
      # Posture monitoring settings
      blurOnsetDelay = 1;
      blurWhenAway = 1;
      deadZone = "0.03";
      intensity = 1;
      pauseOnTheGo = 1;

      # UI settings
      showInDock = 0;
      useCompatibilityMode = 0;
      warningMode = "blur";
    };
  };
}

