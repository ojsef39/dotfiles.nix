{
  flake.modules.homeManager.darwin = _: {
    # installed via mod/brew
    targets.darwin.defaults = {
      # NOTE: Bundle identifier is still posturr
      # https://github.com/tldev/dorso/blob/main/build.sh#L15
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
  };
}
