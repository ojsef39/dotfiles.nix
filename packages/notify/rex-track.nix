# Run a command and report its status to the terminal with OSC 7501 (the
# Program Status Protocol): working while it runs, then done or error. Rex shows
# this on the tab, in Activity and as a notification; other terminals ignore it.
#   rex-track gh pr checks --watch --fail-fast --interval 3
{pkgs}:
pkgs.writeShellApplication {
  name = "rex-track";
  runtimeInputs = [pkgs.coreutils];
  text = ''
    if [ "$#" -eq 0 ]; then
      echo "usage: rex-track <command> [args...]" >&2
      exit 2
    fi

    # app: a stable id from the program name; msg: the command line, base64
    # (the protocol caps msg at 2048 decoded bytes)
    app=$(basename -- "$1" | tr -cd 'A-Za-z0-9_.+-' | cut -c1-32)
    msg=$(printf '%s' "$*" | head -c 2000 | base64 | tr -d '\n')

    # To the terminal itself, so it also works when stdout is piped. BEL ends
    # the sequence (the protocol allows it as well as ESC \\).
    report() {
      { printf '\033]7501;state=%s:app=%s:msg=%s\007' "$1" "$app" "$msg" >/dev/tty; } 2>/dev/null || true
    }

    # Ctrl-C: the protocol says to report idle when the user interrupts
    trap 'report idle; exit 130' INT TERM

    report "working"
    code=0
    "$@" || code=$?
    if [ "$code" -eq 0 ]; then
      report "done"
    else
      report "error"
    fi
    exit "$code"
  '';
}
