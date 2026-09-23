{pkgs}:
pkgs.writeShellApplication {
  name = "send-cooking";
  runtimeInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.libnotify];
  text = ''
    if [[ "$(uname)" == "Darwin" ]]; then
      osascript -e 'display notification "IM DONE COOKING!" with title "Kitty"'
    else
      notify-send "Kitty" "IM DONE COOKING!"
    fi
  '';
}
