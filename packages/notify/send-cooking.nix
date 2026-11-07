{pkgs}:
pkgs.writeShellApplication {
  name = "send-cooking";
  runtimeInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.libnotify];
  text = ''
    if [[ "$(uname)" == "Darwin" ]]; then
      osascript -e 'display notification "IM DONE COOKING!" with title "AI"'
    else
      notify-send "AI" "IM DONE COOKING!"
    fi
  '';
}
