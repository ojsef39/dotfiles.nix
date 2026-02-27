{baseLib, ...}: {
  imports = baseLib.scanPaths ../_personal/system ++ baseLib.scanPaths ./system;
}
