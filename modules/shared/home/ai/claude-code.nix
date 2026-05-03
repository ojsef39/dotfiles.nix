{ai, ...}: let
  # claude-code uses dashes: "claude-sonnet-4-6"
  claudeModel = builtins.replaceStrings ["."] ["-"] ai.model;
in {
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    rulesDir = ai.instructionsDir;
    lspServers = builtins.listToAttrs (map (s: {
        inherit (s) name;
        value = {
          inherit (s) command args;
          extensionToLanguage = s.languageIds;
        };
      })
      ai.lspServers);
    settings = {
      env = {
        ENABLE_LSP_TOOL = "1";
      };
      permissions = {
        allow =
          map (d: "WebFetch(domain:${d})") ai.allowedDomains
          ++ map (p: "Bash(${p})") ai.allowedBashCommands
          ++ ai.allowedMcpTools;
      };
      statusLine = {
        type = "command";
        command = "$HOME/.claude/statusline.sh";
      };
      agentPushNotifEnabled = true;
      model = claudeModel;
      inherit (ai) effortLevel;
    };
  };

  home.file.".claude/statusline.sh" = {
    source = ./statusline.sh;
    executable = true;
  };
}
