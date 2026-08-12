{
  config,
  lib,
  ...
}: let
  cfg = config.ai;
  # claude-code uses dashes: "claude-sonnet-4-6"
  claudeModel = builtins.replaceStrings ["."] ["-"] cfg.model;

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
      agentPushNotifEnabled = true;
      model = claudeModel;
      advisorModel = "opus";
      inherit (cfg) effortLevel;
    };
  };

  home.file.".claude/statusline.sh" = {
    source = ./statusline.sh;
    executable = true;
  };
}
