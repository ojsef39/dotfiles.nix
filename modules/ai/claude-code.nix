{
  flake.modules.homeManager.base = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.ai;
    # Claude Code reads these only from ~/.claude.json, which it also writes itself.
    globalConfig = {
      copyOnSelect = false;
    };
    # claude-code uses dashes: "claude-sonnet-4-6"
    # claudeModel = builtins.replaceStrings ["."] ["-"] cfg.model;
    claudeModel = "opus";

    # Expand { "server-name" = [ "tool" ]; } into Claude Code permission strings.
    # Three naming conventions for server keys:
    #   "some-server"        → mcp__plugin_hm_some-server  (home-manager MCP)
    #   "claude.ai/Server"   → mcp__claude_ai_Server       (claude.ai remote MCP)
    #   "@server"            → mcp__server                 (direct via --mcp-config)
    expandMcpCalls = calls:
      lib.flatten (lib.mapAttrsToList (server: tools: let
        id =
          if lib.hasPrefix "claude.ai/" server
          then "mcp__claude_ai_${lib.removePrefix "claude.ai/" server}"
          else if lib.hasPrefix "@" server
          then "mcp__${lib.removePrefix "@" server}"
          else "mcp__plugin_hm_${builtins.replaceStrings ["/" "."] ["_" "_"] server}";
      in
        map (tool: "${id}__${tool}") tools)
      calls);
  in {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
      rulesDir = cfg.instructionsDir;
      lspServers = builtins.listToAttrs (map (s: {
          inherit (s) name;
          value = {
            inherit (s) command args;
            extensionToLanguage = s.languageIds;
          };
        })
        cfg.lspServers);
      settings = {
        env = {
          ENABLE_LSP_TOOL = "1";
        };
        permissions = {
          allow =
            map (d: "WebFetch(domain:${d})") cfg.allowedDomains
            ++ map (p: "Bash(${p})") cfg.allowedBashCommands
            ++ expandMcpCalls cfg.allowedMcpCalls;
        };
        statusLine = {
          type = "command";
          command = "$HOME/.claude/statusline.sh";
        };
        tui = "fullscreen";
        agentPushNotifEnabled = true;
        autoMemoryEnabled = false;
        model = claudeModel;
        # advisorModel = "opus";
        inherit (cfg) effortLevel;
      };
    };

    home.file.".claude/statusline.sh" = {
      source = ./statusline.sh;
      executable = true;
    };

    home.activation.claudeGlobalConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      file="$HOME/.claude.json"
      lock="$file.lock"
      if [[ -v DRY_RUN ]]; then
        verboseEcho "claudeGlobalConfig: would merge globalConfig into $file"
      else
        # Same lock dir Claude Code takes via proper-lockfile when saving this file.
        tries=0
        until mkdir "$lock" 2>/dev/null; do
          tries=$((tries + 1))
          if [ "$tries" -ge 50 ]; then
            warnEcho "claudeGlobalConfig: $lock held for 5s, skipping"
            break
          fi
          sleep 0.1
        done
        if [ "$tries" -lt 50 ]; then
          (
            tmp=$(mktemp "$file.XXXXXX")
            trap 'rm -f "$tmp"; rmdir "$lock"' EXIT
            [ -s "$file" ] || echo '{}' > "$file"
            if ! ${pkgs.jq}/bin/jq --argjson cfg ${lib.escapeShellArg (builtins.toJSON globalConfig)} '. * $cfg' "$file" > "$tmp"; then
              warnEcho "claudeGlobalConfig: $file is not valid JSON, skipping"
            elif ! ${pkgs.diffutils}/bin/cmp -s "$tmp" "$file"; then
              mv "$tmp" "$file"
            fi
          )
        fi
      fi
    '';
  };
}
