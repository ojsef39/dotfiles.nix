_: {
  # installed via mod/dw/brew
  targets.darwin.defaults = {
    "com.ethanbills.DockDoor" = {
      # Auto-update settings
      SUAutomaticallyUpdate = 1;
      SUEnableAutomaticChecks = 1;
      SUSendProfileInfo = 0;

      # Preview and window behavior
      allowDynamicImageSizing = 1;
      enableDockPreviewGestures = 1;
      enableLivePreview = 0;
      enableLivePreviewForWindowSwitcher = 1;
      useEmbeddedDockPreviewElements = 1;
      openDelay = 0;
      previewHoverAction = "none";
      sizingMultiplier = 7;

      # Window switcher settings
      enableCmdTabEnhancements = 1;
      enableWindowSwitcherGestures = 1;
      enableWindowSwitcherSearch = 0;
      includeHiddenWindowsInSwitcher = 1;
      windowPreviewSortOrder = "recentlyUsed";
      hasSeenCmdTabFocusHint = 1;

      # UI elements
      showActiveAppIndicator = 0;
      enabledTrafficLightButtons = ["toggleFullScreen" "quit" "close" "minimize"];
    };
  };
}
