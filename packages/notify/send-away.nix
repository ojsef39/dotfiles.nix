{pkgs}:
pkgs.writeShellApplication {
  name = "send-away";
  runtimeInputs = with pkgs; [curl jq];
  text = ''
    if [[ $# -lt 1 ]]; then
      echo "Usage: send-away <webhook-file> [message]" >&2
      echo "Example: send-away ~/.config/secrets/ai_discord_webhook \"build done\"" >&2
      exit 2
    fi

    webhook_file="$1"
    if [[ ! -f "$webhook_file" ]]; then
      echo "Error: webhook file not found: $webhook_file" >&2
      exit 1
    fi

    webhook=$(cat "$webhook_file")
    if [[ -z "$webhook" ]]; then
      echo "Error: webhook file is empty: $webhook_file" >&2
      exit 1
    fi

    shift
    message="$*"
    if [[ -z "$message" ]]; then
      message="Task done"
    fi

    # Discord rejects content > 2000 chars
    if [[ ''${#message} -gt 2000 ]]; then
      message="''${message:0:1997}..."
    fi

    payload=$(printf '%s' "$message" | jq -Rs '{content: .}')
    curl -sf -X POST -H "Content-Type: application/json" -d "$payload" "$webhook" >/dev/null
  '';
}
