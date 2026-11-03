---
description: "Applies globally."
applyTo: "**"
---

## GitHub

Prefer the GitHub MCP server (`mcp__plugin_hm_github-mcp-server__*`) over `gh` CLI calls for GitHub operations.
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
