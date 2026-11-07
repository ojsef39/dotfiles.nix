# Open a tab in the JHOFER-Cloud/fleet Rex session (created like the project
# picker would if missing) with k9s on talos-dev (left) and talos-live (right),
# both on non-running pods across all namespaces, switch the app to it, then
# press Shift+A (sort by age) in each.
{pkgs}:
pkgs.writeShellApplication {
  name = "rex-k9s";
  runtimeInputs = [pkgs.jq pkgs.coreutils pkgs.gnugrep];
  text = ''
    label="JHOFER-Cloud/fleet"
    dir="$HOME/CodeProjects/github.com/$label"

    # Picker sessions are labelled " <owner>/<repo>", so ignore leading spaces
    session=$(rex ls --json | jq -r --arg l "$label" \
      'first(.sessions[] | select((.label // "") | ltrimstr(" ") == $l) | .session_id) // empty')
    dev=(k9s --context admin@talos-dev -n all -c 'pp /!running')
    if [ -n "$session" ]; then
      created=$(rex run -s "$session" -c "$dir" --json --label talos-dev -- "''${dev[@]}")
      window=$(jq -r '.window_id' <<<"$created")
      left=$(jq -r '.block_ids[0]' <<<"$created")
    else
      # A new session's first tab is the k9s one, not an extra shell
      created=$(rex new --json -c "$dir" " $label" -- "''${dev[@]}")
      session=$(jq -r '.session_id' <<<"$created")
      window=$(jq -r '.initial_windows[0].window_id' <<<"$created")
      left=$(jq -r '.initial_windows[0].block_ids[0]' <<<"$created")
      rex block rename -s "$session" "$left" talos-dev >/dev/null || true
    fi
    right=$(rex split -s "$session" -c "$dir" --json -b "$left" --split right --label talos-live -- \
      k9s --context admin@talos-live -n all -c 'pp /!running' | jq -r '.block_ids[0]')

    # Follow: show the new tab in the Rex app (if it is connected); without
    # window_id the app returns to the session's last shown tab
    app=$(rex client ls --json | jq -r \
      'first(.clients[] | select(.info.kind == "app" and .connection_state == "connected") | .client_id) // empty')
    if [ -n "$app" ]; then
      rex -C "$app" "do" session.select session_id="$session" window_id="$window" >/dev/null || true
    fi
    rex focus -s "$session" "$left" >/dev/null || true

    # Wait until k9s has drawn its pod table, then sort it. Gives up quietly
    # after ~20s, so a slow cluster just stays unsorted.
    sort_by_age() {
      local screen
      for _ in $(seq 40); do
        # No pipe: grep -q exiting early would SIGPIPE capture and, under
        # pipefail, fail the check even though the table is there
        screen=$(rex capture -s "$session" -b "$1" 2>/dev/null || true)
        if grep -qi 'pods(' <<<"$screen"; then
          sleep 0.5
          rex send -s "$session" -b "$1" 'A'
          return
        fi
        sleep 0.5
      done
    }

    sort_by_age "$left" &
    sort_by_age "$right" &
    wait
  '';
}
