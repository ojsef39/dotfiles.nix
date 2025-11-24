_: let
  claudeSettings = builtins.fromJSON (builtins.readFile ./claude-settings.json);
in {
  programs.claude-code = {
    enable = true;
    settings = claudeSettings;
  };
}
