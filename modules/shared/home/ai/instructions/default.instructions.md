---
description: "Applies globally."
applyTo: "**"
---

## GitHub

Prefer the GitHub MCP server (`mcp__plugin_claude-code-home-manager_github-mcp-server__*`) over `gh` CLI calls for GitHub operations.
Only fall back to `gh` if the required operation has no MCP equivalent.

## Nix environment

This system uses Nix. If a tool is not in PATH, run it with:
`nix run nixpkgs#<package> -- [args]`

## Positive control

Make sure your commands actually work!
Example: empty grep output doesn't necessarily mean clean; it can also mean your command was just wrong.

## Notifications (ignore if you have native notification feature)

When a long task finishes or you need to alert the user:

- **Default**: run `send-cooking` to send a local macOS alert.
- **If the user said they are going away**: run `send-away ~/.config/secrets/ai_discord_webhook "<message>"` to send a Discord notification instead.
  **Critical**: when the user is away, plan the entire task upfront using only pre-approved commands and tools (those in the allowlist) — never trigger anything that would require an approval prompt, since the user won't be there to approve it.
  If you can't complete the task without unapproved tools, say so before they leave.

Message rules for `send-away`:

- Markdown works (`**bold**`, code blocks, etc.) — Discord renders it.
- Real newlines work — use actual newlines in the message, not literal `\n`.
- Messages over 2000 chars are auto-truncated (Discord's hard limit).
- No support for embeds / structured payloads — content only.
