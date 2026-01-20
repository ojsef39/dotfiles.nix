{baseLib, ...}: {
  imports = baseLib.scanPaths ./home;

  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
