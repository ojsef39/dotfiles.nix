---
description: "Applies globally."
applyTo: "**"
---

## Nix environment

This system uses Nix. If a tool is not in PATH, run it with:
`nix run nixpkgs#<package> -- [args]`

## Notifications

When a long task finishes or you need to alert the user:

- **Default**: run `send-cooking` to send a local macOS alert.
- **If the user said they are going away**: run `send-away ~/.config/secrets/ai_discord_webhook "<message>"` to send a Discord notification instead.

Message rules for `send-away`:

- Markdown works (`**bold**`, code blocks, etc.) — Discord renders it.
- Real newlines work — use actual newlines in the message, not literal `\n`.
- Messages over 2000 chars are auto-truncated (Discord's hard limit).
- No support for embeds / structured payloads — content only.
