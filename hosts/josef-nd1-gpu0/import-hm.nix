{baseLib, ...}: {
  imports = baseLib.scanPaths ../_personal/home ++ baseLib.scanPaths ./home;
}
