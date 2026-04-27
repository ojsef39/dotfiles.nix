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
          ++ map (p: "Bash(${p})") ai.allowedBashCommands;
      };
      statusLine = {
        type = "command";
        command = ''input=$(cat); current_dir=$(echo "$input" | jq -r '.workspace.current_dir'); model_name=$(echo "$input" | jq -r '.model.display_name'); output_style=$(echo "$input" | jq -r '.output_style.name'); dir_name=$(basename "$current_dir"); git_branch=$(cd "$current_dir" 2>/dev/null && git branch --show-current 2>/dev/null); git_status=$(cd "$current_dir" 2>/dev/null && git status --porcelain 2>/dev/null | wc -l | tr -d ' '); if [ -n "$git_branch" ]; then if [ "$git_status" -gt 0 ]; then git_info=" ⚡ $git_branch ($git_status)"; else git_info=" ⚡ $git_branch"; fi; else git_info=""; fi; printf "\033[2m%s \033[36m%s\033[39m%s \033[33m[%s]\033[0m" "$model_name" "$dir_name" "$git_info" "$output_style"'';
      };
      model = claudeModel;
      inherit (ai) effortLevel;
    };
  };
}
